package com.visualpathit.account.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.visualpathit.account.utils.CDNHelper;

@ControllerAdvice
public class GlobalModelAttributes {
    
    @Autowired
    private CDNHelper cdnHelper;
    
    @ModelAttribute("cdnHelper")
    public CDNHelper cdnHelper() {
        return cdnHelper;
    }
}
