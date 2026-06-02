package org.example.springboot.config;


import com.aliyun.oss.ClientBuilderConfiguration;
import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.common.auth.CredentialsProviderFactory;
import com.aliyun.oss.common.auth.EnvironmentVariableCredentialsProvider;
import com.aliyun.oss.common.comm.SignVersion;
import com.aliyun.oss.model.ObjectMetadata;
import com.aliyun.oss.model.PutObjectRequest;
import jakarta.annotation.Resource;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

//注入到容器
@Component
@Data
public class AliyunOSSOperator {
    private static final Logger LOGGER = LoggerFactory.getLogger(AliyunOSSOperator.class);

    @Resource
    private OSS ossClient;

    @Resource
    private AliyunOSSProperies ossConfig;

    /**
     * 上传文件到阿里云 OSS
     *
     * @param file 上传的文件
     * @param folder 文件夹路径
     * @return 文件的访问 URL
     */
    public String uploadFile(MultipartFile file, String folder) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("上传文件不能为空");
        }

        // 获取原始文件名
        String originalFilename = file.getOriginalFilename();
        assert originalFilename != null;

        // 生成唯一的文件名
        String extension = getFileExtension(originalFilename);
        String uniqueFileName = generateUniqueFileName(extension);

        // 构建 OSS 对象键名
        String objectKey = buildObjectKey(folder, uniqueFileName);

        try {
            // 设置对象元数据
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());
            metadata.setContentType(file.getContentType());

            // 上传文件
            InputStream inputStream = file.getInputStream();
            PutObjectRequest putObjectRequest = new PutObjectRequest(
                    ossConfig.getBucketName(),
                    objectKey,
                    inputStream,
                    metadata
            );

            ossClient.putObject(putObjectRequest);

            // 生成文件访问 URL
            String fileUrl = buildFileUrl(objectKey);

            LOGGER.info("文件上传成功：{}", fileUrl);
            return fileUrl;

        } catch (Exception e) {
            LOGGER.error("文件上传失败：{}", e.getMessage(), e);
            throw new IOException("文件上传失败：" + e.getMessage(), e);
        }
    }

    /**
     * 批量上传文件
     *
     * @param files 文件列表
     * @param folder 文件夹路径
     * @return 文件 URL 列表
     */
    public String[] uploadMultipleFiles(MultipartFile[] files, String folder) throws IOException {
        if (files == null || files.length == 0) {
            throw new IllegalArgumentException("上传文件不能为空");
        }

        String[] urls = new String[files.length];
        for (int i = 0; i < files.length; i++) {
            urls[i] = uploadFile(files[i], folder);
        }
        return urls;
    }

    /**
     * 删除 OSS 上的文件
     *
     * @param fileUrl 文件 URL 或对象键名
     */
    public void deleteFile(String fileUrl) {
        try {
            // 从 URL 中提取对象键名
            String objectKey = extractObjectKey(fileUrl);

            if (objectKey != null && !objectKey.isEmpty()) {
                ossClient.deleteObject(ossConfig.getBucketName(), objectKey);
                LOGGER.info("文件删除成功：{}", objectKey);
            }
        } catch (Exception e) {
            LOGGER.error("文件删除失败：{}", e.getMessage(), e);
        }
    }

    /**
     * 构建对象键名
     */
    private String buildObjectKey(String folder, String fileName) {
        StringBuilder keyBuilder = new StringBuilder();

        // 添加文件前缀
        if (ossConfig.getFilePrefix() != null && !ossConfig.getFilePrefix().isEmpty()) {
            keyBuilder.append(ossConfig.getFilePrefix());
        }

        // 添加文件夹路径
        if (folder != null && !folder.isEmpty()) {
            keyBuilder.append(folder).append("/");
        }

        // 添加文件名
        keyBuilder.append(fileName);

        return keyBuilder.toString();
    }

    /**
     * 构建文件访问 URL
     */
    private String buildFileUrl(String objectKey) {
        if (ossConfig.getUrlDomain() != null && !ossConfig.getUrlDomain().isEmpty()) {
            // 使用自定义域名
            return ossConfig.getUrlDomain() + "/" + objectKey;
        } else {
            // 使用 OSS 默认域名
            return "https://" + ossConfig.getBucketName() + "." +
                    ossConfig.getEndpoint().replace("https://", "").replace("http://", "") +
                    "/" + objectKey;
        }
    }

    /**
     * 从 URL 中提取对象键名
     */
    private String extractObjectKey(String fileUrl) {
        if (fileUrl == null || fileUrl.isEmpty()) {
            return null;
        }

        // 如果传入的是完整 URL，提取路径部分
        if (fileUrl.startsWith("http")) {
            int domainEndIndex = fileUrl.indexOf("/", fileUrl.indexOf("//") + 2);
            if (domainEndIndex > 0) {
                return fileUrl.substring(domainEndIndex + 1);
            }
        }

        // 否则直接返回
        return fileUrl;
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        int dotIndex = filename.lastIndexOf('.');
        if (dotIndex > 0) {
            return filename.substring(dotIndex);
        }
        return "";
    }

    /**
     * 生成唯一的文件名
     */
    private String generateUniqueFileName(String extension) {
        return System.currentTimeMillis() + "_" + UUID.randomUUID().toString().replace("-", "") + extension;
    }

}
