/*
Navicat MySQL Data Transfer

Source Server         : MySQL8.0.31
Source Server Version : 80031
Source Host           : localhost:3306
Source Database       : seclassdesign

Target Server Type    : MYSQL
Target Server Version : 80031
File Encoding         : 65001

Date: 2023-05-11 21:57:27
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for indice
-- ----------------------------
DROP TABLE IF EXISTS `indice`;
CREATE TABLE `indice` (
  `indice_id` int NOT NULL AUTO_INCREMENT COMMENT '指标id',
  `indice_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '指标名称',
  `indice_weight` double DEFAULT '0' COMMENT '指标权重',
  `indice_value` double DEFAULT '0' COMMENT '指标值',
  `father_id` int NOT NULL DEFAULT '-1' COMMENT '父节点id',
  `operator_id` int DEFAULT NULL COMMENT '算子id',
  `scheme_id` int NOT NULL COMMENT '所属体系id',
  PRIMARY KEY (`indice_id`) USING BTREE,
  KEY `system_id` (`scheme_id`) USING BTREE,
  KEY `operator_id` (`operator_id`) USING BTREE,
  KEY `father_id` (`father_id`),
  CONSTRAINT `indice_ibfk_1` FOREIGN KEY (`scheme_id`) REFERENCES `scheme` (`scheme_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `indice_ibfk_2` FOREIGN KEY (`operator_id`) REFERENCES `operator` (`operator_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `indice_ibfk_3` FOREIGN KEY (`father_id`) REFERENCES `indice` (`indice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of indice
-- ----------------------------

-- ----------------------------
-- Table structure for operator
-- ----------------------------
DROP TABLE IF EXISTS `operator`;
CREATE TABLE `operator` (
  `operator_id` int NOT NULL AUTO_INCREMENT,
  `operator_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`operator_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of operator
-- ----------------------------
INSERT INTO `operator` VALUES ('1', '+');
INSERT INTO `operator` VALUES ('2', '-');
INSERT INTO `operator` VALUES ('3', '*');
INSERT INTO `operator` VALUES ('4', '/');
INSERT INTO `operator` VALUES ('5', 'max');
INSERT INTO `operator` VALUES ('6', 'min');
INSERT INTO `operator` VALUES ('7', 'avg');

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `question1` varchar(255) NOT NULL,
  `answer1` varchar(255) NOT NULL,
  `question2` varchar(255) NOT NULL,
  `answer2` varchar(255) NOT NULL,
  PRIMARY KEY (`question_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `question_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of question
-- ----------------------------

-- ----------------------------
-- Table structure for scheme
-- ----------------------------
DROP TABLE IF EXISTS `scheme`;
CREATE TABLE `scheme` (
  `scheme_id` int NOT NULL AUTO_INCREMENT COMMENT '体系id',
  `scheme_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '体系名字',
  `user_id` int NOT NULL COMMENT '用户id',
  PRIMARY KEY (`scheme_id`) USING BTREE,
  UNIQUE KEY `system_name` (`scheme_name`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  CONSTRAINT `scheme_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of scheme
-- ----------------------------
INSERT INTO `scheme` VALUES ('1', '成绩评价体系', '2');
INSERT INTO `scheme` VALUES ('2', '股票质量评价体系', '2');
INSERT INTO `scheme` VALUES ('3', '大学评价体系', '2');
INSERT INTO `scheme` VALUES ('9', '面条店', '2');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'admin', '123456', '2320876714@qq.com');
INSERT INTO `user` VALUES ('2', '熊睿', '123456', '2320876714@qq.com');
