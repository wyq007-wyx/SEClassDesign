<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>用户管理</title>
    <link rel="stylesheet" href="./css/administratorPage.css">
    <!-- 在线引入最新样式 -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
</head>

<body>
    <div id="app">
        <el-container style="height: 100%; border: 1px solid #eee">
            <!-- 左侧边，导航栏 -->
            <el-aside width="200px" style="background-color: rgb(238, 241, 246)">
                <el-menu default-active="1-1" background-color="#545c64" text-color="#fff" active-text-color="#ffd04b"
                    @select="switchOption">
                    <el-submenu index="1">
                        <template slot="title"><i class="el-icon-message"></i>用户管理</template>
                        <el-menu-item index="1-1">所有用户信息</el-menu-item>
                    </el-submenu>
                </el-menu>
            </el-aside>
            <!-- 右半边 -->
            <el-container>
                <!-- 头 -->
                <el-header style="font-size: 12px;">
                    <!-- 创建新用户的按钮 -->
                    <el-button type="primary" icon="el-icon-edit" style="margin-top: 10px"
                        @click="insertDialogVisible = true" plain>
                        创建新用户</el-button>
                    <!-- 创建新用户的对话框 -->
                    <el-dialog title="创建新用户" :visible.sync="insertDialogVisible" width="30%" center>
                        <div style="height: 250px; overflow: auto">
                            <el-form ref="createUserForm" :model="createUserForm" label-width="80px" :rules="userRule">
                                <el-form-item label="用户名" prop="username">
                                    <el-input v-model="createUserForm.username"></el-input>
                                </el-form-item>
                                <el-form-item label="密码" prop="password">
                                    <el-input v-model="createUserForm.password"></el-input>
                                </el-form-item>
                                <el-form-item label="邮箱地址" prop="email">
                                    <el-input v-model="createUserForm.email"><template slot="append">.com</template>
                                    </el-input>
                                </el-form-item>
                            </el-form>
                        </div>
                        <span slot="footer" class="dialog-footer">
                            <el-button type="primary" @click="submitCreateForm('createUserForm')"
                                style="margin-left: 30px; margin-right: 30px">创建
                            </el-button>
                            <el-button @click="cancelCreate">取消</el-button>
                        </span>
                    </el-dialog>
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
                    <!--点击修改信息，显示修改用户信息的对话框-->
                    <el-dialog title="修改信息" :visible.sync="clickChangeUserInfoFlag" width="30%" center>
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
                            <el-button type="primary" @click="changeInfo" style="margin-left: 30px; margin-right: 30px">
                                修改
                            </el-button>
                            <el-button @click="clickChangeUserInfoFlag = false">取消</el-button>
                        </span>
                    </el-dialog>
                </el-header>
                <!-- 主体 -->
                <el-main>
                    <!-- 模糊查询表单 -->
                    <el-form :inline="true" class="demo-form-inline">
                        <el-form-item label="用户名">
                            <el-input v-model="usernameForQuery" placeholder="请输入用户名"></el-input>
                        </el-form-item>
                        <el-form-item>
                            <el-button icon="el-icon-search" type="primary" @click="fuzzyQueryByUsername">查询
                            </el-button>
                        </el-form-item>
                    </el-form>
                    <!-- 显示所有用户信息 -->
                    <el-table height="67vh"
                        :data="userTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
                        <el-table-column type="index" align="center"></el-table-column>

                        <el-table-column prop="username" label="用户名" align="center">
                        </el-table-column>
                        <el-table-column prop="password" label="密码" align="center">
                        </el-table-column>
                        <el-table-column prop="email" label="邮箱" align="center">
                        </el-table-column>
                        </el-table-column>
                        <el-table-column label="操作" align="center" fixed="right">
                            <template slot-scope="scope">
                                <el-button type="primary" icon="el-icon-edit" size="mini"
                                    @click="clickChangeBtn(scope.row)" circle>
                                </el-button>
                                <el-button type="danger" icon="el-icon-delete" size="mini"
                                    @click="clickDeleteBtn(scope.row)" circle>
                                </el-button>
                            </template>
                        </el-table-column>
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
                //显示当前用户的详细信息
                currentUserInfoDialogVisible: false,
                //点击了修改用户信息按钮
                clickChangeUserInfoFlag: false,
                //新增用户的对话框
                insertDialogVisible: false,
                //用于修改用户的表单
                changeUserForm: {
                    user_id: '',
                    username: '',
                    password: '',
                    email: ''
                },
                //用于创建新用户的表单
                createUserForm: {
                    username: '',
                    password: '',
                    email: ''
                },
                urlHeader: 'http://localhost:2008/SEClassDesign/RequestFromAdminPage.do?',
                //当前登录的用户
                currentUser: {},
                //用户表格数据
                userTableData: [],
                //模糊查询的用户名
                usernameForQuery: '',
                //校验规则
                userRule: {
                    //用户名验证规则
                    username: {
                        type: "string",
                        required: true,
                        message: '请输入用户名',
                        trigger: 'blur'
                    },
                    //密码验证规则
                    password: {
                        type: "string",
                        required: true,
                        message: '请输入密码',
                        trigger: 'blur'
                    },
                    //电子邮箱验证规则
                    email: [{
                            type: "string",
                            required: true,
                            message: '请输入邮箱地址',
                            trigger: 'blur'
                        },
                        {
                            type: 'email',
                            message: '请输入正确的邮箱地址',
                            trigger: ['blur', 'change']
                        }
                    ]
                },
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
            //获取所有的用户信息
            this.getInfo();
        },
        methods: {
            //视图切换
            switchOption(index) {
                this.getInfo();
                this.page.currentPage = 1;
            },
            //向后端发送获取所有数据的请求
            getInfo() {
                console.log("正在从后端获取数据");
                var _this = this;
                axios({
                    method: "post",
                    url: _this.urlHeader + 'request=UserInfoForDisplay'
                }).then(function (resp) {
                    console.log("获取到了……\n" + resp.data);
                    _this.userTableData = resp.data;
                    _this.page.total = _this.userTableData.length;
                })
            },
            //当前用户点击下拉菜单
            operateCurrentUser(command) {
                if (command == 'changeInfo') { //点击了修改信息菜单项
                    this.changeUserForm = JSON.parse(JSON.stringify(this.currentUser)); //为修改表单赋初值
                    this.clickChangeUserInfoFlag = true; //标记为true，显示修改表单
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
            //根据用户名模糊查询
            fuzzyQueryByUsername() {
                console.log("正在从后端获取数据");
                var _this = this;
                axios({
                    method: "post",
                    url: _this.urlHeader + 'request=fuzzyQueryByUsername',
                    data: "username=" + _this.usernameForQuery
                }).then(function (resp) {
                    console.log("获取到了……\n" + resp.data);
                    _this.userTableData = resp.data;
                    let len = resp.data.length; //判断查询到几条记录
                    _this.page.total = len;
                    console.log(len);
                    if (len > 0) {
                        Vue.prototype.$message({
                            message: '共查询到' + len + '条用户记录',
                            type: 'success'
                        });
                    } else {
                        Vue.prototype.$message.error('没有查询到任何用户记录');
                    }
                })
            },
            //提交创建新用户的表单
            submitCreateForm(formName) {
                //表单校验
                this.$refs[formName].validate((valid) => {
                    if (valid) {
                        this.addItem();
                    } else {
                        Vue.prototype.$message.error('请检查表单是否填写完整！');
                        console.log('提交错误');
                        return false;
                    }
                });
            },
            //管理员创建新用户
            addItem() {
                var _this = this;
                //向后端发送异步请求
                axios({
                    method: "post",
                    url: _this.urlHeader + 'request=addUserByAdmin',
                    data: _this.createUserForm
                }).then(function (resp) {
                    _this.insertDialogVisible = false; //关闭对话框
                    _this.createUserForm = {}; //清空表单
                    if (resp.data == 1) {
                        Vue.prototype.$message({
                            message: '成功添加一条记录！',
                            type: 'success'
                        });
                        _this.getInfo(); //刷新页面
                    } else if (resp.data == -1) {
                        Vue.prototype.$message.error('新用户重名！');
                    } else {
                        Vue.prototype.$message.error('添加失败！');
                    }
                })
            },
            //取消新建
            cancelCreate() {
                //重置表单和验证结果
                this.$refs.createUserForm.resetFields();
                //关闭对话框
                this.insertDialogVisible = false;
            },
            //用户点击了表格中的修改按钮
            clickChangeBtn(row) {
                //准备表单数据
                for (let i = 0; i < this.userTableData.length; i++) {
                    if (this.userTableData[i].user_id == row.user_id) {
                        this.changeUserForm = JSON.parse(JSON.stringify(this.userTableData[i]));
                        break;
                    }
                }
                //显示修改对话框
                this.clickChangeUserInfoFlag = true;
            },
            //修改信息
            changeInfo() {
                //准备数据
                var refreshParam;
                var _this = this;
                if (this.changeUserForm.user_id == this.currentUser.user_id) {
                    refreshParam = 'currentUser';
                } else {
                    refreshParam = 'otherUser';
                }
                //向后端发送异步请求
                axios({
                    method: "post",
                    url: _this.urlHeader + 'request=changeUser',
                    data: _this.changeUserForm
                }).then(function (resp) {
                    //关闭修改表单
                    _this.clickChangeUserInfoFlag = false;
                    if (resp.data == 1) {
                        if (refreshParam == 'currentUser') { //如果修改的是当前用户信息，则更新
                            _this.currentUser = _this.changeUserForm;
                        } else { //否则刷新页面
                            _this.getInfo();
                        }
                        Vue.prototype.$message({
                            message: '信息修改成功！',
                            type: 'success'
                        });
                    } else {
                        Vue.prototype.$message.error('修改失败！');
                    }
                })
            },
            //用户点击了删除
            clickDeleteBtn(row) {
                var _this = this;
                Vue.prototype.$confirm('此操作将永久删除该条记录, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(() => { //点击了确定
                    _this.deleteItem(row); //删除
                }).catch(() => { //点击了取消
                    Vue.prototype.$message({
                        type: 'info',
                        message: '已取消删除'
                    });
                });
            },
            //删除一条记录
            deleteItem(row) {
                var url;
                var data;
                var _this = this;
                //准备数据
                url = this.urlHeader + 'request=deleteUserByAdmin';
                data = 'user_id=' + row.user_id;
                //向后端发送异步请求
                axios({
                    method: "post",
                    url: url,
                    data: data //key-value形式
                }).then(function (resp) {
                    let result = resp.data; //返回受影响的行数
                    if (result == 1) { //删除成功
                        Vue.prototype.$message({
                            type: 'success',
                            message: '删除成功!'
                        });
                        _this.getInfo(); //刷新页面
                    } else { //删除失败
                        Vue.prototype.$message.error('删除失败！');
                    }
                })
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