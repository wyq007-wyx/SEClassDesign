package com.dao;

import java.util.Date;
import java.util.List;

import com.pojo.Result;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

@Repository("resultDao")
@Mapper
public interface ResultDao {
	//根据体系id和时间查询结果信息
	List<Result> selectResultBySchemeIdANDTime(@Param("scheme_id") int scheme_id, @Param("time") String time);
	
	//插入结果信息
	int insertResult(List<Result> resList);
}
