package org.example.springboot.service;


import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import io.swagger.v3.oas.annotations.Operation;
import org.example.springboot.common.Result;
import org.example.springboot.config.AliyunOSSOperator;
import org.example.springboot.enumClass.FileType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
public class FileService {
    private static final Logger LOGGER = LoggerFactory.getLogger(FileService.class);

    private final AliyunOSSOperator aliyunOssUtil;

    public FileService(AliyunOSSOperator aliyunOssUtil) {
        this.aliyunOssUtil = aliyunOssUtil;
    }

    @Operation(summary = "文件上传")
    public Result<?> upLoad(MultipartFile file, FileType fileType) {
        if (com.baomidou.mybatisplus.core.toolkit.StringUtils.isBlank(file.getOriginalFilename())) {
            LOGGER.error("文件不存在");
            return Result.error("-1", "文件不存在！");
        }
        LOGGER.info("upload FILE:" + file.getOriginalFilename());
        try {
            String fileUrl = aliyunOssUtil.uploadFile(file, fileType.getTypeName());
            return Result.success(fileUrl);
        } catch (IOException e) {
            LOGGER.error("文件上传失败", e);
            return Result.error("-1", "文件上传失败：" + e.getMessage());
        }
    }

    // Deleted:@DeleteMapping("/remove/{filename}")
    // Deleted:public Result<?> fileRemove(@PathVariable String filename){
    // Deleted:    String filePath="\\img\\"+filename;
    // Deleted:
    // Deleted:    boolean res = FileUtil.deleteFile(filePath);
    // Deleted:
    // Deleted:    return res? Result.success():Result.error("-1","删除失败！");
    // Deleted:
    // Deleted:}

    public List<String> uploadMultiple(List<MultipartFile> files) {
        if (files == null || files.isEmpty()) {
            LOGGER.error("没有文件上传");
            return null;
        }

        List<String> successUrls = new ArrayList<>();
        List<String> failedFiles = new ArrayList<>();

        for (MultipartFile file : files) {
            try {
                if (StringUtils.isEmpty(file.getOriginalFilename())) {
                    failedFiles.add(file.getOriginalFilename() + ": 文件不存在");
                    continue;
                }
                LOGGER.info("upload FILE:" + file.getOriginalFilename());
                String fileUrl = aliyunOssUtil.uploadFile(file, FileType.COMMON.getTypeName());
                successUrls.add(fileUrl);
            } catch (Exception e) {
                LOGGER.error("文件上传时发生异常：" + e.getMessage(), e);
                failedFiles.add(file.getOriginalFilename() + ": 文件上传时发生异常");
            }
        }

        if (!failedFiles.isEmpty()) {
            for (String url : successUrls) {
                aliyunOssUtil.deleteFile(url);
                LOGGER.info("Deleted successfully uploaded file: " + url);
            }
            return null;
        } else {
            return successUrls;
        }
    }
}
