package com.npu.aoxiangbackend.controller;

import com.npu.aoxiangbackend.util.ColoredPrintStream;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

@Controller
@RequestMapping("/static")
public class ResourceController {

    private ColoredPrintStream printer;

    @Autowired
    public ResourceController(ColoredPrintStream printer) {
        this.printer = printer;
    }

    @GetMapping("/**")
    public void getResource(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String path = req.getServletContext().getRealPath(req.getServletPath());
        File file = new File(path);
        if (file.exists() && file.isFile()) {
            try (FileInputStream is = new FileInputStream(file)) {
                is.transferTo(resp.getOutputStream());
                return;
            } catch (IOException ex) {
                printer.shortPrintException(ex);
            }
        }
        resp.getWriter().println("Request Uri is not a valid file.");
    }
}
