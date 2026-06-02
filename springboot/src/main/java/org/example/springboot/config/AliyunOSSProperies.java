package org.example.springboot.config;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "aliyun.oss")

public class AliyunOSSProperies {
    /**
     * 阿里云 OSS Endpoint
     */
    private String endpoint;

    /**
     * 阿里云访问密钥 ID
     */
    private String accessKeyId;

    /**
     * 阿里云访问密钥密码
     */
    private String accessKeySecret;

    /**
     * OSS Bucket 名称
     */
    private String bucketName;

    /**
     * 文件访问域名（用于生成完整的 URL）
     */
    private String urlDomain;

    /**
     * 文件路径前缀
     */
    private String filePrefix = "files/";

    /**
     * 创建 OSS Client Bean
     */
    @Bean
    public OSS ossClient() {
        return new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);
    }
}