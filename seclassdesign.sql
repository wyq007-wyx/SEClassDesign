/*
 Navicat Premium Data Transfer

 Source Server         : mysql8
 Source Server Type    : MySQL
 Source Server Version : 80031
 Source Host           : localhost:3306
 Source Schema         : seclassdesign

 Target Server Type    : MySQL
 Target Server Version : 80031
 File Encoding         : 65001

 Date: 14/05/2023 15:23:20
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for indice
-- ----------------------------
DROP TABLE IF EXISTS `indice`;
CREATE TABLE `indice`  (
  `indice_id` int NOT NULL AUTO_INCREMENT,
  `indice_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `indice_weight` double NULL DEFAULT 0,
  `indice_value` double NULL DEFAULT 0,
  `father_id` int NULL DEFAULT -1,
  `operator_id` int NULL DEFAULT NULL,
  `scheme_id` int NOT NULL,
  PRIMARY KEY (`indice_id`) USING BTREE,
  INDEX `system_id`(`scheme_id`) USING BTREE,
  INDEX `operator_id`(`operator_id`) USING BTREE,
  CONSTRAINT `indice_ibfk_1` FOREIGN KEY (`scheme_id`) REFERENCES `scheme` (`scheme_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `indice_ibfk_2` FOREIGN KEY (`operator_id`) REFERENCES `operator` (`operator_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of indice
-- ----------------------------
INSERT INTO `indice` VALUES (1, '总成绩', 13, 0, -1, 1, 1);
INSERT INTO `indice` VALUES (2, '平时成绩', 54, 0, 1, 1, 1);
INSERT INTO `indice` VALUES (3, '期中成绩', 44, 0, 1, 1, 1);
INSERT INTO `indice` VALUES (4, '期末成绩', 0, 0, 1, 1, 1);
INSERT INTO `indice` VALUES (6, '作业成绩', 0, 0, 2, 1, 1);
INSERT INTO `indice` VALUES (7, '期末考试成绩', 0, 0, 4, 1, 1);
INSERT INTO `indice` VALUES (8, '课设成绩', 0, 0, 4, 1, 1);
INSERT INTO `indice` VALUES (21, 'q', 0, 0, 8, NULL, 1);
INSERT INTO `indice` VALUES (22, 'ffa', 0, 0, 7, NULL, 1);
INSERT INTO `indice` VALUES (24, '', 0, 0, 7, NULL, 1);
INSERT INTO `indice` VALUES (31, '测试成绩', 0, 0, 2, NULL, 1);
INSERT INTO `indice` VALUES (37, '', 0, 0, 2, NULL, 1);
INSERT INTO `indice` VALUES (38, '', 0, 0, 6, NULL, 1);

-- ----------------------------
-- Table structure for operator
-- ----------------------------
DROP TABLE IF EXISTS `operator`;
CREATE TABLE `operator`  (
  `operator_id` int NOT NULL AUTO_INCREMENT,
  `operator_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`operator_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operator
-- ----------------------------
INSERT INTO `operator` VALUES (1, '+');
INSERT INTO `operator` VALUES (2, '-');
INSERT INTO `operator` VALUES (3, '*');
INSERT INTO `operator` VALUES (4, '/');
INSERT INTO `operator` VALUES (5, 'max');
INSERT INTO `operator` VALUES (6, 'min');
INSERT INTO `operator` VALUES (7, 'avg');

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question`  (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `question1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `answer1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `question2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `answer2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`question_id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  CONSTRAINT `question_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question
-- ----------------------------

-- ----------------------------
-- Table structure for scheme
-- ----------------------------
DROP TABLE IF EXISTS `scheme`;
CREATE TABLE `scheme`  (
  `scheme_id` int NOT NULL AUTO_INCREMENT COMMENT '体系id',
  `scheme_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '体系名字',
  `user_id` int NOT NULL COMMENT '用户id',
  PRIMARY KEY (`scheme_id`) USING BTREE,
  UNIQUE INDEX `system_name`(`scheme_name`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  CONSTRAINT `scheme_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheme
-- ----------------------------
INSERT INTO `scheme` VALUES (1, '成绩评价体系', 2);
INSERT INTO `scheme` VALUES (3, '大学评价体系', 2);
INSERT INTO `scheme` VALUES (5, '测试体系', 2);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '123456', '2320876714@qq.com');
INSERT INTO `user` VALUES (2, '齐胜震', 'qsz', '3056059732@qq.com');
INSERT INTO `user` VALUES (3, 'xxx', '123456', '2320876714@qq.com');

SET FOREIGN_KEY_CHECKS = 1;
