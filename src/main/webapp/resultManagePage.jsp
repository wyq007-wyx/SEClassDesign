<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>运行结果</title>
    <!-- 在线引入最新样式 -->
     <link href='./bootstrap/css/bootstrap.css' media='all' rel='stylesheet' type='text/css' />
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
    <link rel="stylesheet" href="./css/indiceManagePage.css">
</head>

<body>
    <div id="app">
        <el-container style="height: 100%; border: 1px solid #eee">
                <el-header>
                    <a class="btn btn-primary" style="margin-top:12px;" v-bind:href="url">导出计算结果</a>
                </el-header>
                <!-- 所有模板信息 -->
                <el-main>
                    <!-- 显示所有体系信息 -->
                    <!-- <el-table height="77vh"
                        :data="schemeTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
                        <el-table-column label="序号" type="index" width="400" align="center"></el-table-column>
                        <el-table-column prop="indice.indice_value" label="最终结果"  align="center">
                        </el-table-column>
                        <el-table-column label="操作"  align="center" fixed="right">
                            <template slot-scope="scope">
                                <el-button size="mini" @click="displaySchemeByTree(scope.row)" plain>体系树
                                </el-button>
                            </template>
                        </el-table-column>
                    </el-table> -->
                    <el-table height="77vh"
                        :data="tableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
                        <template>
                            <el-table-column label="序号" type="index" v-bind="index" align="center"></el-table-column>
                            <el-table-column align="center"
                            v-for="(column, columnIndex) in tableData[0]"
                            :key="columnIndex"
                            :label="tableData[0][columnIndex].indice_name"
                            >
                            <template slot-scope="scope">
                                {{tableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)[scope.$index][columnIndex].indice_value}}
                            </template>
                            </el-table-column>
                            <el-table-column label="操作"  align="center" fixed="right">
                                <template slot-scope="scope">
                                    <el-button size="mini" @click="displaySchemeByTree(scope.row)" plain>体系树
                                    </el-button>
                                </template>
                            </el-table-column>
                        </template>
                    </el-table>
                </el-main>
                <!--分页工具条-->
                <el-footer>
                    <div class="block">
                        <el-pagination @current-change="handleCurrentChange" :current-page="page.currentPage"
                            :page-size="page.pageSize" layout="total, prev, pager, next, jumper" :total="page.total">
                        </el-pagination>
                    </div>
                </el-footer>
        </el-container>
    </div>
</body>
<script src="js/axios-0.18.0.js"></script>
<!-- import Vue before Element -->
<!-- <script src="js/vue.js"></script> -->
<script src="https://unpkg.com/vue@2/dist/vue.js"></script>
<!-- import JavaScript -->
<!-- <script src="element-ui/lib/index.js"></script> -->
<script src="https://unpkg.com/element-ui/lib/index.js"></script>
<script src="js/echarts.js"></script>
<script>
    import Vue from 'vue';
</script>
<script>
    new Vue({
        el: '#app',
        data() {
            return {
                //表格用的体系信息
                schemeTableData: [],
                //转为表格
                listSchemeTableData:[],
                //用于分页
                page: {
                    //当前页数
                    currentPage: 1,
                    //分页展示，每页10条
                    pageSize: 10,
                    //总条数
                    total: 0
                },
                //树列表
                treeStructlist:[],
                //下载链接
                url: '#',
                index:'',
                tableData:[
                   [
                    {   
                        indice_id: '',
                        indice_name: '',
                        indice_weight: 0,
                        indice_value: '',
                        father_id: '',
                        operator_id: '',
                        scheme_id: ''
                    },
                   ],
                ],
                //树的数据
                tree_struct: {
                    name: '',
                    indice: {
                        indice_id: '',
                        indice_name: '',
                        indice_weight: 0,
                        indice_value: '',
                        father_id: '',
                        operator_id: '',
                        scheme_id: ''
                    },
                    children: [
                        {
                            name: '',
                            indice: {},
                            children: []
                        }
                    ]
                },
            }
        },
        mounted() {  
            let temp = ${sessionScope.tableData};
            console.log(typeof temp);
            console.log(temp);
            var list=[];
            for(var i of temp){
                var indicelist=[];
                for(var j of JSON.parse(i)){
                    indicelist.push(JSON.parse(j));
                }
                list.push(indicelist);
            }
            //console.log(list);
            this.tableData=list;
            var str ='['+sessionStorage.getItem('jsontreelist')+']';
            this.treeStructlist = JSON.parse(str);
            this.getSchemeInfo();
            this.url = 'http://localhost:2008/SEClassDesign/RequestFromIndiceManagePage.do?request=downloadCalResult&scheme_id=' + this.treeStructlist[0].indice.scheme_id;
        },
        methods: {
            //获取所有结果信息
            getSchemeInfo() {
                console.log('获取到了所有树形结果信息:\n' + this.treeStructlist);
                this.schemeTableData=this.treeStructlist;
                this.page.total = this.schemeTableData.length;
            },
            //以体系树形式展示
            displaySchemeByTree(row) {
                console.log('展示体系树');
                var tindex=(this.page.currentPage-1)*this.page.pageSize+this.index;
                var tree=JSON.stringify(this.treeStructlist[tindex]);
                sessionStorage.setItem('chosentree',tree);
                window.location.href = "http://localhost:2008/SEClassDesign/resultTree.jsp";
            },
            //当页码改变
            handleCurrentChange(val) {
                console.log('当前页' + val);
                //修改页码
                this.page.currentPage = val;
            },
            //获取字段列表
            getColumns(){
                if(this.treeStructlist!=null&&this.treeStructlist!=[]){
                    this.tree_struct=this.treeStructlist[0];

                }
            },
            //获取列名称

        }
    })
</script>

</html>