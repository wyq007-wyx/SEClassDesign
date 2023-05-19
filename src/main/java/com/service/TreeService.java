package com.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.alibaba.excel.EasyExcelFactory;
import com.alibaba.excel.ExcelReader;
import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.event.AnalysisEventListener;
import com.alibaba.fastjson.JSON;
import com.dao.IndiceDao;
import com.dao.TreeDao;
import com.pojo.IndiceInfo;
import com.pojo.TreeNode;
import com.util.Util;

import jxl.Workbook;
import jxl.write.Label;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;


@Service("treeService")
public class TreeService {
	@Resource
	private TreeDao treeDao;

	@Resource
	private IndiceDao indiceDao; 

	private TreeNode tree = null;
	
	public TreeService() {}

	/**
	 * 添加一个指标节点
	 * 
	 * @param indiceInfo
	 * @return
	 */
	public int addTreeNode(IndiceInfo indiceInfo) {
		int indice_id = treeDao.addTreeNode(indiceInfo);
		return indice_id;
	}

	/**
	 * @param system_id 体系id
	 * @return 返回一个体系树的JSON序列
	 */
	public String getTreeNode(int scheme_id) {
		// 体系树
		IndiceInfo rootInfo = treeDao.selectRoot(scheme_id, -1);
		System.out.println("rootinfo:" + rootInfo);
		if (rootInfo == null)
			return "";
		tree = new TreeNode(rootInfo.getIndice_name(), null, rootInfo);
		dfs(tree, scheme_id);
		String Jsontree = JSON.toJSONString(tree);
		return Jsontree;
	}

	/**
	 * 当前节点获取孩子指标列表
	 * 
	 * @param infolist
	 * @return
	 */
	private List<TreeNode> getChildren(List<IndiceInfo> infolist) {
		List<TreeNode> children = new ArrayList<>();
		for (IndiceInfo i : infolist) {
			TreeNode t = new TreeNode(i.getIndice_name(), null, i);
			children.add(t);
		}
		return children;
	}

	/**
	 * 更新节点信息
	 * 
	 * @param node
	 * @return
	 */
	public int updateIndice(IndiceInfo node) {
		return treeDao.updateIndice(node);
	}

	/**
	 * 递归求每一个节点的孩子列表
	 * 
	 * @param node
	 * @param scheme_id
	 */
	private void dfs(TreeNode node, int scheme_id) {
		List<IndiceInfo> infoList = treeDao.selectIndiceBySystemIdAndFatherId(scheme_id,
				node.getIndice().getIndice_id());
		node.setChildren(getChildren(infoList));
		if (node.getChildren().size() == 0) {
			return;
		}
		for (TreeNode n : node.getChildren()) {
			dfs(n, scheme_id);
		}
	}

	/**
	 * 删除指标树和它的所有指标
	 * 
	 * @param scheme_id
	 * @return
	 */
	public int deleteTreeAndInDice(int sid) {
		/// 先删除体系下的所有指标
		int deletenums = treeDao.deleteSchemeIndice(sid);
		// 再删除体系
		int deletesnums = treeDao.deleteScheme(sid);
		System.out.println(deletesnums);
		return deletenums;
	}

	/**
	 * 删除体系树上的某个节点及其子节点
	 * 
	 * @param sid
	 * @return
	 */
	public int deleteTreeNode(int indice_id) {
		dfsForDelete(null, indice_id);
		return 1;
	}

	public void dfsForDelete(IndiceInfo root, int indice_id) {
		List<IndiceInfo> children;
		if (root == null) {
			children = treeDao.selectChildrenByFatherId(indice_id);
		} else {
			children = treeDao.selectChildrenByFatherId(root.getIndice_id());
		}
		for (IndiceInfo child : children) {
			dfsForDelete(child, indice_id);
		}
		if (root == null) {
			treeDao.deleteIndice(indice_id);
		} else {
			treeDao.deleteIndice(root.getIndice_id());
		}
	}

	public String checkInstanceValid(int scheme_id) {
		IndiceInfo rootInfo = treeDao.selectRoot(scheme_id, -1);
		System.out.println("rootinfo:" + rootInfo);
		if (rootInfo == null)
			return "";
		tree = new TreeNode(rootInfo.getIndice_name(), null, rootInfo);
		dfs(tree, scheme_id);
		if (!checkWeight(tree)) {
			return "weight_err";
		} else if (!checkOperator(tree)) {
			return "op_err";
		} else {
			return "success";
		}

	}

	public boolean checkOperator(TreeNode node) {
		if (node.getChildren() == null || node.getChildren().size() == 0) {
			return true;
		} else {
			if (node.getIndice().getOperator_id() != null) {
				for (TreeNode child : node.getChildren()) {
					if (!checkOperator(child))
						return false;
				}
				return true;
			} else {
				return false;
			}

		}
	}

	public boolean checkWeight(TreeNode node) {
		if (node.getChildren() == null || node.getChildren().size() == 0)
			return true;
		else {
			int sum = 0;
			for (TreeNode child : node.getChildren()) {
				sum += child.getIndice().getIndice_weight();
			}
			if (sum == 100) {
				for (TreeNode child : node.getChildren()) {
					if (!checkWeight(child)) {
						System.out.println("节点1id" + child.getIndice().getIndice_id());
						return false;
					}
				}
				return true;
			} else {
				System.out.println("节点2id" + node.getIndice().getIndice_id());
				return false;
			}
		}
	}
	/**
	 * 获取每一行的计算结果
	 * @param dataFile 数据文件
	 * @param scheme_id 体系id
	 * @return List存了每一次计算后的根节点
	 * @throws BiffException
	 * @throws IOException
	 */
	public List<TreeNode> getTreeList(File dataFile, int scheme_id){
		List<IndiceInfo> ans = new ArrayList<>();
		List<String> indiceNames = new ArrayList<>();//指标名列表
		List<List<Double>> indiceValues = new ArrayList<>();//指标值列表
		this.readExcel(dataFile, indiceNames, indiceValues);//读取Excel文件中的值
		//运行数据
		List<TreeNode> treeList=new ArrayList<>();
		IndiceInfo root = this.treeDao.selectRoot(scheme_id, -1);
		for(List<Double> indiceValue : indiceValues) {
			Map<String, Double> map = new HashMap<>();
			for(int i = 0;i < indiceValue.size();i++) {
				map.put(indiceNames.get(i), indiceValue.get(i));
			}
			TreeNode treeRoot=new TreeNode();
			this.calculate(root, map,treeRoot);
			ans.add(root);
			treeList.add(treeRoot);
			root = this.treeDao.selectRoot(scheme_id, -1);
		}
		return treeList;
	}
	/**
	 * EasyExcel读取Excel文件中的内容
	 * @param dataFile 数据文件
	 * @param indiceNames 所有的指标名
	 * @param indiceValues 所有的指标值
	 */
	public void readExcel(File dataFile, List<String> indiceNames, List<List<Double>> indiceValues){
		ExcelReader excelReader = EasyExcelFactory.read(dataFile, null, new AnalysisEventListener<Object>() {
            // 监听器方法，每读取一行数据就调用一次
            @Override
            public void invoke(Object object, AnalysisContext context) {
            	@SuppressWarnings("unchecked") 
                Map<String, String> map = (HashMap<String, String>) object;
                if (context.readRowHolder().getRowIndex() == 0) { // 第一行是indiceName
                	indiceNames.addAll(map.values());
                } else { // 后面的行是indiceValue
                	//把这一行的数据存入list
                    List<Double> indiceValue = new ArrayList<>();
                    for(String value : map.values()) {
                    	try {
                    		indiceValue.add(Double.parseDouble(value));
                    	}catch(NumberFormatException e) {
                    		System.out.println("错误的单元格：" + value);
                    		break;
                    	}
                	}
                    indiceValues.add(indiceValue);
                }
            }
            // 读取完成后执行的操作
            @Override
            public void doAfterAllAnalysed(AnalysisContext context) {
            	System.out.println("Excel文件解析成功，共" + indiceNames.size() + "列，" + indiceValues.size() + "行");
            }
        }).headRowNumber(0).build();
        excelReader.read();
        excelReader.finish();
	}
	/**
	 * 计算树的所有节点的值
	 * @param node 结点
	 * @param map 指标名称和指标值的映射
	 * @return 根节点的值
	 */
	public double calculate(IndiceInfo node, Map<String, Double> map,TreeNode fatherNode) {
		double result = 0.0;
		List<IndiceInfo> children = this.treeDao.selectChildrenByFatherId(node.getIndice_id());// 获取所有的子节点
		List<TreeNode> childrenNodes=new ArrayList<>();
		
		if (children.size() == 0) {
			result = map.get(node.getIndice_name());
			double ret=Double.parseDouble(String.format("%.2f",result));
			node.setIndice_value(result);//保存中间结果
			fatherNode.setName(node.getIndice_name());//设置treenode的名称
			fatherNode.setIndice(node);//treenode的indice
			fatherNode.setChildren(childrenNodes);//treenode的children
			return ret;
		}
		
		int operator_id = node.getOperator_id();
		if(operator_id == 7) {//计算平均值
			double sum = 0.0;
			for(IndiceInfo child : children) {
				TreeNode tnode=new TreeNode();
				sum += this.calculate(child, map,tnode);
				childrenNodes.add(tnode);
			}
			result = sum / children.size();
			node.setIndice_value(Double.parseDouble(String.format("%.2f",result)));//保存中间结果
			fatherNode.setChildren(childrenNodes);
			fatherNode.setIndice(node);
			fatherNode.setName(node.getIndice_name());
		}else if(operator_id == 1){
			TreeNode tnode=new TreeNode();
			result = this.calculate(children.get(0), map,tnode) * children.get(0).getIndice_weight() / 100;
			childrenNodes.add(tnode);
			for (int i = 1; i < children.size(); i++) {
				TreeNode tnode1=new TreeNode();
				result = this.getResult(result, operator_id, this.calculate(children.get(i), map,tnode1) * children.get(i).getIndice_weight() / 100);
				childrenNodes.add(tnode1);
			}
			node.setIndice_value(Double.parseDouble(String.format("%.2f",result)));//保存中间结果
			fatherNode.setChildren(childrenNodes);
			fatherNode.setIndice(node);
			fatherNode.setName(node.getIndice_name());
		}else {
			TreeNode tnode=new TreeNode();
			result = this.calculate(children.get(0), map,tnode);
			childrenNodes.add(tnode);
			for (int i = 1; i < children.size(); i++) {
				TreeNode tnode1=new TreeNode();
				result = this.getResult(result, operator_id, this.calculate(children.get(i), map,tnode1));
				childrenNodes.add(tnode1);
			}
			node.setIndice_value(Double.parseDouble(String.format("%.2f",result)));//保存中间结果
			fatherNode.setChildren(childrenNodes);
			fatherNode.setIndice(node);
			fatherNode.setName(node.getIndice_name());
		}
		return result;
	}
	/**
	 * 根据不同的算子id执行不同的计算操作
	 * @param srcRes 左操作数
	 * @param operator_id 算子id
	 * @param targetRes 右操作数
	 * @return 结果
	 */
	public double getResult(double srcRes, int operator_id, double targetRes) {
		switch (operator_id) {
			case 1: {
				return srcRes + targetRes;
			}
			case 2: {
				return srcRes - targetRes;
			}
			case 3: {
				return srcRes * targetRes;
			}
			case 4: {
				return srcRes / targetRes;
			}
			case 5: {
				return Math.max(srcRes, targetRes);
			}
			case 6: {
				return Math.min(srcRes, targetRes);
			}
			default: {
				return 0.0;
			}
		}
	}
	/**
	 * 写入表头：所有的指标名
	 * @param sheet 工作表
	 * @param node 结点
	 * @param col 写在第几列
	 * @throws Exception
	 */
	public void writeIndiceName(WritableSheet sheet, TreeNode node) throws Exception {
		sheet.addCell(new Label(colIndex++, 0, node.getName()));//添加单元格
		List<TreeNode> children = node.getChildren();//获取孩子
		if(children == null) {
			return;
		}
		for(TreeNode child : children) {//给每一个孩子添加
			this.writeIndiceName(sheet, child);
		}
	}
	/**
	 * 写入每一行计算结果
	 * @param sheet 工作表
	 * @param node 结点
	 * @param row 写在第几行
	 * @param col 写在第几列
	 * @throws Exception
	 */
	public void writeIndiceValue(WritableSheet sheet, TreeNode node, int row) throws Exception {
		sheet.addCell(new jxl.write.Number(colIndex++, row, node.getIndice().getIndice_value()));//添加单元格
		List<TreeNode> children = node.getChildren();//获取孩子
		if(children == null) {
			return;
		}
		for(TreeNode child : children) {//给每一个孩子添加
			this.writeIndiceValue(sheet, child, row);
		}
	}
	public int colIndex = 0;
	/**
	 * 结果写入Excel文件
	 * @param list 结果信息
	 * @param filepath 文件存储的路径
	 * @param scheme_name 体系名
	 * @param user_id 用户名
	 * @throws Exception
	 */
	public void writeIntoExcel(List<TreeNode> list, String filepath, String scheme_name, int user_id) throws Exception {
		String filename = scheme_name + "-" + user_id + ".xls";
		File file = new File(filepath, filename);
		if(file.exists()) {//如果文件存在，删除重新创建
			file.delete();
			file.createNewFile();
		}
		WritableWorkbook wb = Workbook.createWorkbook(file);
		WritableSheet sheet = wb.createSheet("sheet1", 0);
		TreeNode root = list.get(0);
		//创建表头
		this.colIndex = 0;
		this.writeIndiceName(sheet, root);
		//写入每一行数据
		for(int i = 0;i < list.size();i++) {
			this.colIndex = 0;
			this.writeIndiceValue(sheet, list.get(i), i + 1);
		}
		wb.write();
		wb.close();
	}
}
