package com.visualpathit.account.utils;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class CDNHelper {
    
    @Value("${cdn.domain:}")
    private String cdnDomain;
    
    @Value("${cdn.enabled:false}")
    private boolean cdnEnabled;
    
    public String getCSSUrl(String fileName) {
        if (cdnEnabled && cdnDomain != null && !cdnDomain.isEmpty()) {
            return cdnDomain + "/css/" + fileName;
        }
        return "/resources/css/" + fileName;
    }
    
    public String getJSUrl(String fileName) {
        if (cdnEnabled && cdnDomain != null && !cdnDomain.isEmpty()) {
            return cdnDomain + "/js/" + fileName;
        }
        return "/resources/js/" + fileName;
    }
    
    public String getImageUrl(String imagePath) {
        if (cdnEnabled && cdnDomain != null && !cdnDomain.isEmpty()) {
            return cdnDomain + "/images/" + imagePath;
        }
        return "/resources/Images/" + imagePath;
    }
    
    public boolean isCDNEnabled() {
        return cdnEnabled;
    }
}
