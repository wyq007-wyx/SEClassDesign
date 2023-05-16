package com.util;

import java.io.File;

import javax.servlet.http.HttpServletRequest;

public class Util {
	/**
	 * 获取保存计算结果的路径
	 * @param request
	 * @return
	 */
	public static String getCalcResultPath(HttpServletRequest request) {
		String path = request.getSession().getServletContext().getRealPath("/calculateResult");//服务器保存计算结果
		File filePath = new File(path);
		if (!filePath.exists() || !filePath.isDirectory()) {
			System.out.println("目录不存在，创建目录:" + filePath);
			filePath.mkdir();
		}
		return path;
	}
}
