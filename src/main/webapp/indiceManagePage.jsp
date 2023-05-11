<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>指标管理</title>
    <!-- 在线引入最新样式 -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
    <link rel="stylesheet" href="./css/indiceManagePage.css">
</head>

<body>
    <div id="app">
        <el-container style="height: 100%; border: 1px solid #eee">
            <!-- 左侧边，导航栏 -->
            <el-aside width="200px" style="background-color: rgb(238, 241, 246)">
                <el-menu default-active="1-1" background-color="#545c64" text-color="#fff" active-text-color="#ffd04b"
                    @select="switchPage">
                    <el-submenu index="1">
                        <template slot="title"><i class="el-icon-message"></i>列表</template>
                        <el-menu-item index="1-1">所有列表信息</el-menu-item>
                    </el-submenu>
                    <el-submenu index="2">
                        <template slot="title"><i class="el-icon-menu"></i>体系树</template>
                        <el-menu-item index="2-1">创建体系树</el-menu-item>
                    </el-submenu>
                    <el-menu-item index="3"><i class="el-icon-video-play"></i>运行</el-menu-item>
                </el-menu>
            </el-aside>
            <!-- 右半边 -->
            <el-container>
                <!-- 头 -->
                <el-header style="font-size: 12px;">
                    <!-- 创建新体系的按钮 -->
                    <el-button v-show="pageNo == 1" type="primary" icon="el-icon-edit" style="margin-top: 10px"
                        @click="createNewScheme" plain>
                        创建新体系</el-button>
                    <!-- 右上角显示用户名，是一个下拉菜单，可以进行修改和退出登录 -->
                    <el-dropdown split-button type="primary" @click="currentUserInfoDialogVisible = true"
                        @command="operateCurrentUser">
                        {{this.currentUser.username}}
                        <el-dropdown-menu slot="dropdown">
                            <el-dropdown-item command="changeInfo">修改信息</el-dropdown-item>
                            <el-dropdown-item command="logout">退出登录</el-dropdown-item>
                        </el-dropdown-menu>
                    </el-dropdown>
                    <!-- 点击用户名，显示用户详细信息的对话框 -->
                    <el-dialog title="详细信息" :visible.sync="currentUserInfoDialogVisible" width="30%">
                        <div class="showDetail">
                            <el-form label-position="left" inline class="show-detail-table">
                                <el-form-item label="用户名">
                                    <span>{{this.currentUser.username}}</span>
                                </el-form-item>
                                <el-form-item label="密码">
                                    <span>{{this.currentUser.password}}</span>
                                </el-form-item>
                                <el-form-item label="电子邮箱">
                                    <span>{{this.currentUser.email}}</span>
                                </el-form-item>
                            </el-form>
                        </div>
                    </el-dialog>
                    <!--点击修改信息，显示修改当前用户信息的对话框-->
                    <el-dialog title="修改用户信息" :visible.sync="clickChangeCurrentUserBtn" width="30%" center>
                        <div style="height: 250px; overflow: auto">
                            <el-form ref="form" :model="changeUserForm" label-width="80px">
                                <el-form-item label="用户ID">
                                    <!-- 用户ID不允许修改，禁用状态 -->
                                    <el-input v-model="changeUserForm.user_id" disabled></el-input>
                                </el-form-item>
                                <el-form-item label="用户名">
                                    <el-input v-model="changeUserForm.username"></el-input>
                                </el-form-item>
                                <el-form-item label="密码">
                                    <el-input v-model="changeUserForm.password" show-password></el-input>
                                </el-form-item>
                                <el-form-item label="邮箱地址">
                                    <el-input v-model="changeUserForm.email"><template slot="append">.com</template>
                                    </el-input>
                                </el-form-item>
                            </el-form>
                        </div>
                        <span slot="footer" class="dialog-footer">
                            <el-button type="primary" @click="changeInfo('currentUser')"
                                style="margin-left: 30px; margin-right: 30px">修改
                            </el-button>
                            <el-button @click="clickChangeCurrentUserBtn = false">取消</el-button>
                        </span>
                    </el-dialog>
                </el-header>

                <el-main v-if="pageNo==1">
                    <!-- 查询表单 -->
                    <el-form :inline="true" class="demo-form-inline">
                        <el-form-item label="体系名称">
                            <el-input v-model="schemeNameForQuery" placeholder="请输入体系名称"></el-input>
                        </el-form-item>
                        <el-form-item>
                            <el-button icon="el-icon-search" type="primary" @click="fuzzyQueryBySchemeName">模糊查询
                            </el-button>
                        </el-form-item>
                    </el-form>
                    <!-- 显示所有体系信息 -->
                    <el-table height="66vh"
                        :data="schemeTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
                        <el-table-column type="index" align="center"></el-table-column>
                        <el-table-column prop="scheme_id" label="体系号" align="center">
                        </el-table-column>
                        <el-table-column prop="scheme_name" label="体系名称" align="center">
                        </el-table-column>
                        <el-table-column label="操作" align="center" fixed="right">
                            <template slot-scope="scope">
                                <el-button size="mini" @click="displayScheme(scope.row)" plain>详情</el-button>
                                <el-button size="mini" @click="changeScheme(scope.row)" plain>修改</el-button>
                                <el-button type="danger" size="mini" @click="deleteScheme(scope.row)" plain>删除
                                </el-button>
                                <el-button size="mini" @click="displaySchemeByTree(scope.row)" plain disabled>体系树
                                </el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                    <el-drawer v-bind:title="schemeDrawerTitle" :visible.sync="schemeDetailDrawerVisible"
                        :before-close="handleSchemeDrawerClose">
                        <span>我来啦!</span>
                    </el-drawer>
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
<script>
    import Vue from 'vue';
</script>
<script>
    new Vue({
        el: '#app',
        data() {
            return {
                pageNo: 1,
                currentUser: {},
                urlHeader: 'http://localhost:2008/SEClassDesign/RequestFromIndiceManagePage.do?',
                currentUserInfoDialogVisible: false, //是否显示当前用户详细信息的对话框
                clickChangeCurrentUserBtn: false, //是否点击修改当前用户信息按钮
                //用于修改用户的表单
                changeUserForm: {
                    user_id: '',
                    username: '',
                    password: '',
                    email: ''
                },
                //表格用的体系信息
                schemeTableData: [],
                //查询用的体系信息
                schemeNameForQuery: '',
                //显示体系的指标信息的抽屉是否显示
                schemeDetailDrawerVisible: false,
                //单个体系指标信息用于抽屉中的表格展示
                singleSchemeDetailInfo: [],
                //用于展示体系指标信息的抽屉的标题，是体系名
                schemeDrawerTitle: '',
                //用于分页
                page: {
                    //当前页数
                    currentPage: 1,
                    //分页展示，每页6条
                    pageSize: 6,
                    //总条数
                    total: 0
                }
            }
        },
        mounted() { //HTML页面渲染成功，就获取所有用户的信息    
            this.currentUser = ${sessionScope.currentUser}; //从session中获取当前正在登录的对象
            this.getSchemeInfo();
        },
        methods: {
            //页面切换
            switchPage(index) {
                if (index == '1-1') { //列表
                    this.pageNo = 1;
                    this.getSchemeInfo();
                } else if (index == '2-1') { //体系树
                    this.pageNo = 2;

                } else { //运行
                    this.pageNo = 3;

                }
            },
            //获取所有体系信息
            getSchemeInfo() {
                var _this = this;
                axios({
                    method: 'get',
                    url: _this.urlHeader + 'request=SchemeInfoForDisplay&user_id=' + this.currentUser
                        .user_id
                }).then(function (resp) {
                    console.log('获取到了所有体系信息:\n' + resp.data);
                    _this.schemeTableData = resp.data;
                    _this.page.total = _this.schemeTableData.length;
                })
            },
            //点击创建新体系
            createNewScheme() {
                var _this = this;
                this.$prompt('请输入新的体系名称', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    inputPattern: /^[a-zA-Z0-9\u4E00-\u9FA5]{1,10}$/,
                    inputErrorMessage: '体系名称格式不正确'
                }).then(({
                    value
                }) => {
                    var data = {
                        user_id: _this.currentUser.user_id,
                        scheme_name: value
                    };
                    //创建新体系
                    axios({
                        method: "post",
                        url: _this.urlHeader + 'request=createNewScheme',
                        data: data
                    }).then(function (resp) {
                        console.log("获取到了……\n" + resp.data); //创建成功
                        //刷新页面
                        if (resp.data == 1) {
                            Vue.prototype.$message({
                                message: '创建成功！',
                                type: 'success'
                            });
                            _this.getSchemeInfo();
                        }
                    })
                }).catch(() => {
                    this.$message({
                        type: 'info',
                        message: '取消创建'
                    });
                });
            },
            //当前用户 点击下拉菜单
            operateCurrentUser(command) {
                if (command == 'changeInfo') { //点击了修改信息菜单项
                    this.changeUserForm = JSON.parse(JSON.stringify(this.currentUser)); //为修改表单赋初值
                    this.clickChangeCurrentUserBtn = true; //标记为true，显示修改表单
                } else { //点击了退出登录菜单项
                    var _this = this;
                    axios({
                        method: 'get',
                        url: _this.urlHeader + 'request=logout'
                    }).then(function (resp) {
                        if (resp.data == 'success') {
                            window.location.href = "http://localhost:2008/SEClassDesign/login.jsp";
                        }
                    })
                }
            },
            //修改信息
            changeInfo(param) {
                //准备数据
                var url;
                var data;
                var _this = this;
                if (param == 'currentUser') { //如果是修改当前用户
                    url = this.urlHeader + 'request=changeCurrentUser';
                    data = this.changeUserForm;
                }
                //向后端发送异步请求
                axios({
                    method: "post",
                    url: url,
                    data: data
                }).then(function (resp) {
                    //关闭修改表单
                    if (param == 'currentUser') {
                        _this.clickChangeCurrentUserBtn = false;
                    }
                    if (resp.data == 1) {
                        if (param == 'currentUser') { //如果修改的是当前用户信息，则更新
                            _this.currentUser = _this.changeUserForm;
                        }
                        Vue.prototype.$message({
                            message: '修改成功！',
                            type: 'success'
                        });
                    } else {
                        Vue.prototype.$message.error('修改失败！');
                    }
                })
            },
            //根据体系名称模糊查询
            fuzzyQueryBySchemeName() {
                console.log("正在从后端获取数据");
                var url = this.urlHeader + 'request=fuzzyQueryBySchemeName';
                var _this = this;
                axios({
                    method: "post",
                    url: url,
                    data: "scheme_name=" + _this.schemeNameForQuery + '&user_id=' + _this.currentUser
                        .user_id
                }).then(function (resp) {
                    console.log("获取到了……\n" + resp.data);
                    _this.schemeTableData = resp.data;
                    let len = resp.data.length; //判断查询到几条记录
                    _this.page.total = len;
                    console.log(len);
                    if (len > 0) {
                        Vue.prototype.$message({
                            message: '共查询到' + len + '条体系记录',
                            type: 'success'
                        });
                    } else {
                        Vue.prototype.$message.error('没有查询到任何体系记录');
                    }
                })
            },
            //展示体系的指标详情
            displayScheme(row) {
                console.log('展示体系列表');
                //准备数据
                this.schemeDrawerTitle = row.system_name;//抽屉标题
                this.getSingleSchemeDetailInfo();//获取单个体系的所有指标信息
                //表格数据
                this.schemeDetailDrawerVisible = true;
            },
            //获取单个体系的所有指标信息
            getSingleSchemeDetailInfo(row){
                var _this = this;
                var data = 'scheme_id=' + row.scheme_id + '&user_id=' + this.currentUser.user_id;
                axios({
                    method: 'post',
                    url: _this.urlHeader + 'request=SingleSchemeDetailInfo',
                    data: data
                }).then(function (resp) {
                    console.log('获取到了体系的所有指标信息:\n' + resp.data);
                    _this.singleSchemeDetailInfo = resp.data;
                })
            },
            //关闭抽屉前的操作
            handleSchemeDrawerClose(done) {
                schemeDetailDrawerVisible = false;
                done();
            },
            //修改体系
            changeScheme(row) {
                var _this = this;
                this.$prompt('请输入新的体系名称', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    inputPattern: /^[a-zA-Z0-9\u4E00-\u9FA5]{1,10}$/,
                    inputErrorMessage: '体系名称格式不正确'
                }).then(({
                    value
                }) => {
                    var data = {
                        user_id: _this.currentUser.user_id,
                        scheme_id: row.scheme_id,
                        scheme_name: value
                    };
                    //修改体系名称
                    axios({
                        method: "post",
                        url: _this.urlHeader + 'request=changeScheme',
                        data: data
                    }).then(function (resp) {
                        console.log("获取到了……\n" + resp.data); //创建成功
                        //刷新页面
                        if (resp.data == 1) {
                            Vue.prototype.$message({
                                message: '修改成功！',
                                type: 'success'
                            });
                            _this.getSchemeInfo();
                        }
                    })
                }).catch(() => {
                    this.$message({
                        type: 'info',
                        message: '取消修改'
                    });
                });
            },
            //删除体系
            deleteScheme(row) {
                var _this = this;
                Vue.prototype.$confirm('此操作将永久删除该条记录, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(() => { //点击了确定
                    //删除一个体系
                    var data = 'scheme_id=' + row.scheme_id;
                    axios({
                        method: "post",
                        url: _this.urlHeader + 'request=deleteScheme',
                        data: data
                    }).then(function (resp) {
                        console.log("获取到了……\n" + resp.data); //创建成功
                        //刷新页面
                        if (resp.data == 1) {
                            Vue.prototype.$message({
                                message: '删除成功！',
                                type: 'success'
                            });
                            _this.getSchemeInfo();
                        }
                    })
                }).catch(() => { //点击了取消
                    Vue.prototype.$message({
                        type: 'info',
                        message: '已取消删除'
                    });
                });
            },
            //以体系树形式展示
            displaySchemeByTree(row) {
                console.log('展示体系树');
            },
            //当页码改变
            handleCurrentChange(val) {
                console.log('当前页' + val);
                //修改页码
                this.page.currentPage = val;
            }
        }
    })
</script>

</html>