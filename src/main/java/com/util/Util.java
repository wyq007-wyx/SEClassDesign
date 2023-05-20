package com.util;

import java.io.File;
import java.util.List;

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
	/**
	 * 判断src中的字符串是否都出现在target中
	 * @param src 源列表
	 * @param target 目标列表
	 * @return true:都出现；false：不是都出现
	 */
	public static boolean judge(List<String> src, List<String> target) {
		if(src.size() == target.size()) {
			for(String str : src) {
				if(!target.contains(str)) {
					return false;
				}
			}
			return true;
		}
		return false;
	}
}
