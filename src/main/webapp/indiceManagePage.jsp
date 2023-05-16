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
                <el-menu :default-active="pageNo" background-color="#545c64" text-color="#fff"
                    active-text-color="#ffd04b" @select="switchPage">
                    <el-submenu index="1">
                        <template slot="title"><i class="el-icon-message"></i>列表</template>
                        <el-menu-item index="1-1">所有体系模板</el-menu-item>
                        <el-menu-item index="1-2">所有体系实例</el-menu-item>
                    </el-submenu>
                    <el-submenu index="2">
                        <template slot="title"><i class="el-icon-menu"></i>体系树</template>
                        <el-menu-item index="2-1">创建体系树</el-menu-item>
                    </el-submenu>
                </el-menu>
            </el-aside>
            <!-- 右半边 -->
            <el-container>
                <!-- 头 -->
                <el-header style="font-size: 12px;">
                    <!-- 创建新体系的按钮 -->
                    <el-button v-show="pageNo == '1-1'" type="primary" icon="el-icon-edit" style="margin-top: 10px"
                        @click="createNewScheme" plain>
                        创建新体系</el-button>
                    <el-button v-show="pageNo == '1-1'" type="primary" icon="el-icon-edit" style="margin-top: 10px"
                        @click="importSchemeTree" plain>
                        导入体系树</el-button>
                    <!-- 导入体系树，xml文件 -->
                    <el-dialog :title="upload.title" :visible.sync="upload.open" width="400px" append-to-body>
                        <el-upload ref="upload" :limit="1" accept="upload.accept" :action="upload.url"
                            :data="upload.additionalData" :disabled="upload.isUploading" name="treeFile" :before-upload="beforeAvatarUpload"
                            :on-progress="handleFileUploadProgress" :on-success="handleFileSuccess" :auto-upload="false"
                            drag>
                            <i class="el-icon-upload"></i>
                            <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
                            <div class="el-upload__tip" style="color:red" slot="tip">{{this.upload.tips}}</div>
                        </el-upload>
                        <div slot="footer" class="dialog-footer">
                            <el-button type="primary" @click="submitImportCourse">确 定</el-button>
                            <el-button @click="cancelUploadFile">取 消</el-button>
                        </div>
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
                <!-- 所有模板信息 -->
                <el-main v-if="pageNo=='1-1'">
                    <!-- 查询表单 -->
                    <el-form :inline="true" class="demo-form-inline">
                        <el-form-item label="体系模板名称">
                            <el-input v-model="schemeNameForQuery" placeholder="请输入体系模板名称"></el-input>
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
                        <el-table-column prop="scheme_id" label="模板号" align="center">
                        </el-table-column>
                        <el-table-column prop="scheme_name" label="模板名称" align="center">
                        </el-table-column>
                        <el-table-column label="操作" align="center" fixed="right">
                            <template slot-scope="scope">
                                <el-button size="mini" @click="displayScheme(scope.row)" plain>详情</el-button>
                                <el-button size="mini" @click="changeScheme(scope.row)" plain>修改</el-button>
                                <el-button type="danger" size="mini" @click="deleteScheme(scope.row)" plain>删除
                                </el-button>
                                <el-button size="mini" @click="displaySchemeByTree(scope.row)" plain>体系树
                                </el-button>
                                <el-button size="mini" @click="createInstanceByTemplate(scope.row)" plain>实例化
                                </el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                    <!-- 点击查看体系详情，展开右侧抽屉 -->
                    <el-drawer v-bind:title="schemeDrawerTitle" :visible.sync="schemeDetailDrawerVisible"
                        direction="rtl" size="50%">
                        <!-- 创建新指标的按钮 -->
                        <el-button type="primary" icon="el-icon-edit" style="margin: 0 0 10px 10px;"
                            @click="clickAddIndiceBtn" plain>
                            创建新指标</el-button>
                        <!-- 显示所有指标信息 -->
                        <el-table :data="singleSchemeDetailInfo" height="90%">
                            <el-table-column type="index" align="center"></el-table-column>
                            <el-table-column prop="indice_id" label="指标id" align="center">
                            </el-table-column>
                            <el-table-column prop="indice_name" label="指标名称" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.indice_name) == 'undefined' ? '无' : scope.row.indice_name }}</template>
                            </el-table-column>
                            <el-table-column prop="indice_weight" label="指标权重" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.indice_weight) == 'undefined' ? '无' : scope.row.indice_weight / 100 }}</template>
                            </el-table-column>
                            <el-table-column prop="father_id" label="父节点id" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.father_id) == 'undefined' ? '无' : scope.row.father_id }}</template>
                            </el-table-column>
                            <el-table-column prop="operator_id" label="算子" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.operator_id) == 'undefined' ? '无' : scope.row.operator_id }}</template>
                            </el-table-column>
                            <el-table-column label="操作" align="center" fixed="right">
                                <template slot-scope="scope">
                                    <el-button type="primary" icon="el-icon-edit" size="mini"
                                        @click="clickChangeIndiceBtn(scope.row)" circle>
                                    </el-button>
                                    <el-button type="danger" icon="el-icon-delete" size="mini"
                                        @click="clickDeleteIndiceBtn(scope.row)" circle>
                                    </el-button>
                                </template>
                            </el-table-column>
                        </el-table>
                        <!-- 内部抽屉：添加、修改指标 -->
                        <el-drawer v-bind:title="innerDrawerTitle" :append-to-body="true" :show-close="false"
                            :visible.sync="innerDrawerVisible">
                            <div>
                                <el-form ref="addOrChangeIndiceForm" :model="indiceForm" label-width="120px">
                                    <el-form-item label="指标名称" prop="indice_name">
                                        <el-input v-model="indiceForm.indice_name"></el-input>
                                    </el-form-item>
                                    <el-form-item label="指标权重" prop="indice_weight">
                                        <el-slider v-model="indiceForm.indice_weight" :format-tooltip="formatTooltip">
                                        </el-slider>
                                    </el-form-item>
                                    <el-form-item label="父节点id" prop="father_id">
                                        <el-input v-model="indiceForm.father_id"></el-input>
                                    </el-form-item>
                                    <el-form-item label="算子" prop="operator_id">
                                        <el-select v-model="indiceForm.operator_id" placeholder="请选择算子">
                                            <el-option v-for="item in operators" :label="item.operator_description"
                                                :value="item.operator_id" :key="item.operator_id">
                                            </el-option>
                                        </el-select>
                                    </el-form-item>
                                    <el-form-item label="所属体系id" prop="scheme_id">
                                        <el-input v-model="indiceForm.scheme_id" disabled></el-input>
                                    </el-form-item>
                                </el-form>
                                <div style="position: fixed; bottom: 0; width: 100%; padding-bottom: 20px;">
                                    <el-button @click="innerDrawerVisible = false"
                                        style="float: left; width: 12vw; margin-left: 2vw;">取 消</el-button>
                                    <el-button type="primary" @click="addOrChangeIndice"
                                        style="float: left; width: 12vw; margin-left: 2vw;">
                                        确 定</el-button>
                                </div>
                            </div>
                        </el-drawer>
                    </el-drawer>
                </el-main>
                <!-- 所有体系实例 -->
                <el-main v-else-if="pageNo=='1-2'">
                    <!-- 查询表单 -->
                    <el-form :inline="true" class="demo-form-inline">
                        <el-form-item label="体系实例名称">
                            <el-input v-model="schemeNameForQuery" placeholder="请输入体系实例名称"></el-input>
                        </el-form-item>
                        <el-form-item>
                            <el-button icon="el-icon-search" type="primary" @click="fuzzyQueryBySchemeName">模糊查询
                            </el-button>
                        </el-form-item>
                    </el-form>
                    <!-- 显示所有体系实例信息 -->
                    <el-table height="66vh"
                        :data="schemeTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
                        <el-table-column type="index" align="center"></el-table-column>
                        <el-table-column prop="scheme_id" label="实例号" align="center">
                        </el-table-column>
                        <el-table-column prop="scheme_name" label="实例名称" align="center">
                        </el-table-column>
                        <el-table-column label="操作" align="center" fixed="right">
                            <template slot-scope="scope">
                                <el-button size="mini" @click="displayScheme(scope.row)" plain>详情</el-button>
                                <el-button size="mini" @click="changeScheme(scope.row)" plain>修改</el-button>
                                <el-button type="danger" size="mini" @click="deleteScheme(scope.row)" plain>删除
                                </el-button>
                                <el-button size="mini" @click="displaySchemeByTree(scope.row)" plain>体系树
                                </el-button>
                                <el-button size="mini" @click="clickExecuteBtn(scope.row)" plain>运行
                                </el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                    <!-- 点击查看体系详情，展开右侧抽屉 -->
                    <el-drawer v-bind:title="schemeDrawerTitle" :visible.sync="schemeDetailDrawerVisible"
                        direction="rtl" size="50%">
                        <!-- 创建新指标的按钮 -->
                        <el-button type="primary" icon="el-icon-edit" style="margin: 0 0 10px 10px;"
                            @click="clickAddIndiceBtn" plain>
                            创建新指标</el-button>
                        <!-- 显示所有指标信息 -->
                        <el-table :data="singleSchemeDetailInfo" height="90%">
                            <el-table-column type="index" align="center"></el-table-column>
                            <el-table-column prop="indice_id" label="指标id" align="center">
                            </el-table-column>
                            <el-table-column prop="indice_name" label="指标名称" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.indice_name) == 'undefined' ? '无' : scope.row.indice_name }}</template>
                            </el-table-column>
                            <el-table-column prop="indice_weight" label="指标权重" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.indice_weight) == 'undefined' ? '无' : scope.row.indice_weight / 100 }}</template>
                            </el-table-column>
                            <el-table-column prop="father_id" label="父节点id" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.father_id) == 'undefined' ? '无' : scope.row.father_id }}</template>
                            </el-table-column>
                            <el-table-column prop="operator_id" label="算子" align="center">
                                <template
                                    slot-scope="scope">{{ typeof(scope.row.operator_id) == 'undefined' ? '无' : scope.row.operator_id }}</template>
                            </el-table-column>
                            <el-table-column label="操作" align="center" fixed="right">
                                <template slot-scope="scope">
                                    <el-button type="primary" icon="el-icon-edit" size="mini"
                                        @click="clickChangeIndiceBtn(scope.row)" circle>
                                    </el-button>
                                    <el-button type="danger" icon="el-icon-delete" size="mini"
                                        @click="clickDeleteIndiceBtn(scope.row)" circle>
                                    </el-button>
                                </template>
                            </el-table-column>
                        </el-table>
                        <!-- 内部抽屉：添加、修改指标 -->
                        <el-drawer v-bind:title="innerDrawerTitle" :append-to-body="true" :show-close="false"
                            :visible.sync="innerDrawerVisible">
                            <div>
                                <el-form ref="addOrChangeIndiceForm" :model="indiceForm" label-width="120px">
                                    <el-form-item label="指标名称" prop="indice_name">
                                        <el-input v-model="indiceForm.indice_name"></el-input>
                                    </el-form-item>
                                    <el-form-item label="指标权重" prop="indice_weight">
                                        <el-slider v-model="indiceForm.indice_weight" :format-tooltip="formatTooltip">
                                        </el-slider>
                                    </el-form-item>
                                    <el-form-item label="父节点id" prop="father_id">
                                        <el-input v-model="indiceForm.father_id"></el-input>
                                    </el-form-item>
                                    <el-form-item label="算子" prop="operator_id">
                                        <el-select v-model="indiceForm.operator_id" placeholder="请选择算子">
                                            <el-option v-for="item in operators" :label="item.operator_description"
                                                :value="item.operator_id" :key="item.operator_id">
                                            </el-option>
                                        </el-select>
                                    </el-form-item>
                                    <el-form-item label="所属体系id" prop="scheme_id">
                                        <el-input v-model="indiceForm.scheme_id" disabled></el-input>
                                    </el-form-item>
                                </el-form>
                                <div style="position: fixed; bottom: 0; width: 100%; padding-bottom: 20px;">
                                    <el-button type="primary" @click="addOrChangeIndice"
                                        style="float: left; width: 12vw; margin-left: 2vw;">
                                        确 定</el-button>
                                    <el-button @click="innerDrawerVisible = false"
                                        style="float: left; width: 12vw; margin-left: 2vw;">取 消</el-button>
                                </div>
                            </div>
                        </el-drawer>
                    </el-drawer>
                </el-main>

                <el-main v-else>

                </el-main>
                <!--分页工具条-->
                <el-footer v-if="pageNo=='1-1' || pageNo=='1-2'">
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
<script src="js/echarts.js"></script>
<script>
    import Vue from 'vue';
</script>
<script>
    new Vue({
        el: '#app',
        data() {
            return {
                pageNo: '1-1',
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
                //所有的算子
                operators: [],
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
                //要显示哪个体系
                schemeIDForDisplay: '',
                //内部抽屉是否显示
                innerDrawerVisible: false,
                //内部抽屉的名字
                innerDrawerTitle: '',
                //新增或修改指标的表单
                indiceForm: {},
                //导入体系树需要的数据
                upload: {
                    // 是否显示弹出层（用户导入）
                    open: false,
                    //接收的文件类型
                    accept: '',
                    // 弹出层标题（用户导入）
                    title: '',
                    // 是否禁用上传
                    isUploading: false,
                    // 是否更新已经存在的用户数据
                    updateSupport: 0,
                    //需要附带的数据
                    additionalData: {},
                    //提示信息
                    tips: '',
                    // 上传的地址
                    url: ''
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
            this.uploadAdditionalData = {
                user_id: this.currentUser.user_id
            }; //上传文件时附带的数据
            this.getSchemeInfo(0);
            this.getAllOperator(); //获取所有的算子
        },
        methods: {
            //页面切换
            switchPage(index) {
                this.pageNo = index;
                if (index == '1-1') { //所有的体系模板
                    this.getSchemeInfo(0);
                } else if (index == '1-2') { //所有的体系实例
                    this.getSchemeInfo(1);
                } else { //创建体系树
                    this.createNewScheme();
                }
            },
            //获取所有的算子
            getAllOperator() {
                var _this = this;
                axios({
                    method: 'get',
                    url: _this.urlHeader + 'request=getAllOperators'
                }).then(function (resp) {
                    console.log('获取到了所有算子信息:\n' + resp.data);
                    _this.operators = resp.data;
                })
            },
            //获取所有体系信息
            getSchemeInfo(isInstance) {
                var _this = this;
                axios({
                    method: 'get',
                    url: _this.urlHeader + 'request=SchemeInfoForDisplay&user_id=' + this.currentUser
                        .user_id + '&isInstance=' + isInstance
                }).then(function (resp) {
                    console.log('获取到了所有体系信息:\n' + resp.data);
                    _this.schemeTableData = resp.data;
                    _this.page.total = _this.schemeTableData.length;
                    if (_this.page.total % _this.page.pageSize == 0) { //如果删除后当前页无内容，需要减少页码
                        _this.page.currentPage = _this.page.total / _this.page.pageSize;
                    }
                    if (_this.page.currentPage == 0) {
                        _this.page.currentPage = 1;
                    }
                })
            },
            //点击创建新体系
            createNewScheme() {
                var _this = this;
                this.$prompt('请输入新的体系名称', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    inputPattern: /^[a-zA-Z0-9\u4E00-\u9FA5]{1,20}$/,
                    inputErrorMessage: '体系名称格式不正确'
                }).then(({
                    value
                }) => {
                    var data = {
                        user_id: _this.currentUser.user_id,
                        scheme_name: value,
                        isInstance: 0
                    };
                    //创建新体系
                    axios({
                        method: "post",
                        url: _this.urlHeader + 'request=createNewScheme',
                        data: data
                    }).then(function (resp) {
                        //console.log("resp.data" + resp.data); //创建成功
                        //打开体系树页面
                        if (resp.data > 0) {
                            Vue.prototype.$message({
                                message: '创建成功！',
                                type: 'success'
                            });
                            _this.getSchemeInfo(0);
                            if (_this.pageNo == '2-1') { //直接打开体系树页面
                                window.location.href =
                                    "http://localhost:2008/SEClassDesign/getSystemTree.do?scheme_id=" +
                                    resp.data + '&isInstance=0';
                            }
                        } else {
                            _this.$message.error('创建失败！可能存在同名体系');
                        }
                    })
                }).catch(() => {
                    this.$message({
                        type: 'info',
                        message: '取消创建'
                    });
                    if (_this.pageNo == '2-1') { //回到首页
                        _this.pageNo = '1-1';
                        _this.getSchemeInfo(0);
                    }
                });
            },
            //当前用户点击下拉菜单
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
                var isInstance = this.pageNo == '1-1' ? 0 : 1;
                axios({
                    method: "post",
                    url: url,
                    data: "scheme_name=" + _this.schemeNameForQuery + '&user_id=' + _this.currentUser
                        .user_id +
                        '&isInstance=' + isInstance
                }).then(function (resp) {
                    console.log("获取到了……\n" + resp.data);
                    _this.schemeTableData = resp.data;
                    let len = resp.data.length; //判断查询到几条记录
                    _this.page.total = len;
                    console.log(len);
                    if (len > 0) {
                        Vue.prototype.$message({
                            message: '共查询到' + len + '条记录',
                            type: 'success'
                        });
                    } else {
                        Vue.prototype.$message.error('没有查询到任何记录');
                    }
                })
            },
            //展示体系的指标详情
            displayScheme(row) {
                //准备数据
                this.schemeDrawerTitle = row.scheme_name; //抽屉标题
                this.schemeIDForDisplay = row.scheme_id; //修改变量
                this.getSingleSchemeDetailInfo(row.scheme_id); //获取单个体系的所有指标信息
                //打开抽屉
                this.schemeDetailDrawerVisible = true;
            },
            //获取单个体系的所有指标信息
            getSingleSchemeDetailInfo(id) {
                var _this = this;
                var data = 'scheme_id=' + id + '&user_id=' + this.currentUser.user_id;
                axios({
                    method: 'post',
                    url: _this.urlHeader + 'request=SingleSchemeDetailInfo',
                    data: data
                }).then(function (resp) {
                    //console.log('获取到了体系的所有指标信息:\n' + resp.data);
                    _this.singleSchemeDetailInfo = resp.data;
                })
            },
            //点击了新增指标的按钮
            clickAddIndiceBtn() {
                this.innerDrawerTitle = '新增指标';
                this.indiceForm = {};
                this.indiceForm.scheme_id = this.schemeIDForDisplay;
                this.innerDrawerVisible = true; //显示内部抽屉
            },

            //点击了修改指标的按钮
            clickChangeIndiceBtn(row) {
                this.innerDrawerTitle = '修改指标';
                this.indiceForm = JSON.parse(JSON.stringify(row)); //获取表单数据，深拷贝
                this.innerDrawerVisible = true; //显示内部抽屉
            },
            //添加或修改指标
            addOrChangeIndice() {
                var _this = this;
                var url, message;
                if (this.innerDrawerTitle == '新增指标') {
                    url = _this.urlHeader + 'request=createIndice';
                    message = '创建成功！';
                } else {
                    url = _this.urlHeader + 'request=changeIndice';
                    message = '修改成功！';
                }
                //创建或修改体系
                axios({
                    method: "post",
                    url: url,
                    data: _this.indiceForm
                }).then(function (resp) {
                    console.log("获取到了……\n" + resp.data); //创建成功
                    //刷新页面
                    if (resp.data == 1) {
                        Vue.prototype.$message({
                            message: message,
                            type: 'success'
                        });
                        _this.innerDrawerVisible = false; //关闭表单
                        _this.$refs.addOrChangeIndiceForm.resetFields(); //重置表单域
                        _this.getSingleSchemeDetailInfo(_this.indiceForm.scheme_id); //刷新
                    }
                })
            },
            //点击了删除指标的按钮
            clickDeleteIndiceBtn(row) {
                var _this = this;
                var tips, url, data;
                var callback;
                if (row.father_id == -1) {
                    callback = 0;
                    tips = '该节点是根节点,此操作将永久删除该体系, 是否继续?';
                    url = 'http://localhost:2008/SEClassDesign/deleteSystemTree.do';
                    data = 'scheme_id=' + row.scheme_id;
                } else {
                    callback = 1;
                    tips = '此操作将永久删除该节点及其子节点, 是否继续?';
                    url = 'http://localhost:2008/SEClassDesign/deleteNode.do';
                    data = 'indice_id=' + row.indice_id;
                }
                Vue.prototype.$confirm(tips, '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning',
                    cancelButtonClass: 'el-button--default el-button--small el-button--cancel'
                }).then(() => { //点击了确定
                    //删除一个指标
                    axios({
                        method: "post",
                        url: url,
                        data: data
                    }).then(function (resp) {
                        if (callback == 1) {
                            console.log("获取到了……\n" + resp.data); //删除成功
                            //刷新页面
                            Vue.prototype.$message({
                                message: '删除成功！',
                                type: 'success'
                            });
                            _this.getSingleSchemeDetailInfo(row.scheme_id);
                        } else {
                            Vue.prototype.$message({
                                type: 'success',
                                message: '删除成功!'
                            });
                            _this.schemeDetailDrawerVisible = false; //关闭外部抽屉
                            _this.getSchemeInfo(_this.pageNo == '1-1' ? 0 : 1); //刷新页面
                        }
                    })
                }).catch(() => { //点击了取消
                    Vue.prototype.$message({
                        type: 'info',
                        message: '已取消删除'
                    });
                });
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
                            _this.getSchemeInfo(_this.pageNo == '1-1' ? 0 : 1);
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
                    type: 'warning',
                    cancelButtonClass: 'el-button--default el-button--small el-button--cancel'
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
                            _this.getSchemeInfo(_this.pageNo == '1-1' ? 0 : 1);
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
                var isInstance = this.pageNo == '1-1' ? 0 : 1;
                window.location.href = "http://localhost:2008/SEClassDesign/getSystemTree.do?scheme_id=" + row
                    .scheme_id + "&scheme_name=" + row.scheme_name + '&isInstance=' + isInstance;
            },
            //根据模板创建实例
            createInstanceByTemplate(row) {
                var data = {
                    scheme_id: row.scheme_id,
                    user_id: this.currentUser.user_id,
                    scheme_name: '',
                    isInstance: 1
                };
                var _this = this;
                this.$prompt('请输入体系实例名称', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    inputPattern: /^[a-zA-Z0-9\u4E00-\u9FA5]{1,20}$/,
                    inputErrorMessage: '体系实例名称格式不正确'
                }).then(({
                    value
                }) => {
                    data.scheme_name = value;
                    //创建新体系实例
                    axios({
                        method: "post",
                        url: _this.urlHeader + 'request=createSchemeInstance',
                        data: data
                    }).then(function (resp) {
                        //console.log("resp.data" + resp.data); //创建成功
                        //打开体系树页面
                        if (resp.data > 0) {
                            Vue.prototype.$message({
                                message: '创建体系实例成功！',
                                type: 'success'
                            });
                            _this.getSchemeInfo(1);
                            _this.pageNo = '1-2';
                        } else {
                            _this.$message.error('创建失败！可能存在同名体系实例');

                        }
                    })
                }).catch(() => {
                    this.$message({
                        type: 'info',
                        message: '取消创建'
                    });
                });
            },
            //点击运行按钮
            clickExecuteBtn(row) {
                var _this = this;
                axios({
                    method: 'post',
                    url: 'http://localhost:2008/SEClassDesign/checkInstance.do',
                    data: 'scheme_id=' + row.scheme_id
                }).then(function (resp) {
                    if (resp.data == 'weight_err') {
                        _this.$message.error('权重设置错误，请检查权重！');
                    } else if (resp.data == 'op_err') {
                        _this.$message.error('部分指标尚未配置算子，请配置算子！');
                    } else {
                        //弹出上传excel窗口
                        _this.upload.title = '上传excel';
                        _this.upload.url = 'http://localhost:2008/SEClassDesign/executeTree.do';
                        _this.upload.tips = '提示：仅允许导入Excel格式文件！';
                        _this.upload.accept = '.xlsx, .xls';
                        _this.upload.additionalData = {
                            scheme_id: row.scheme_id
                        };
                        _this.upload.open = true;
                    }
                });
            },
            //滑块数值格式化
            formatTooltip(val) {
                return val / 100;
            },
            //当页码改变
            handleCurrentChange(val) {
                console.log('当前页' + val);
                //修改页码
                this.page.currentPage = val;
            },
            //Excel批量导入
            //点击导入体系树
            importSchemeTree() {
                this.upload.title = '导入体系树模板';
                this.upload.accept = '.xml, .json';
                this.upload.url =
                    'http://localhost:2008/SEClassDesign/RequestFromIndiceManagePage.do?request=uploadTreeFile';
                this.upload.additionalData = {
                    user_id: this.currentUser.user_id
                };
                this.upload.tips = '提示：仅允许导入“xml”或“json”格式文件！';
                this.upload.open = true;
            },
            //上传文件前检验文件类型
            beforeAvatarUpload(file) {
                var fileType1 = (file.type === 'text/xml' || file.type === 'application/json');
                var fileType2 = (file.type === 'application/vnd.ms-excel' || file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                if(this.pageNo == '1-1'){
                    if(!fileType1){
                        this.$message.error('上传文件只能是 JSON / XML 格式!');
                        return false;
                    }
                    
                }else{
                    if(!fileType2){
                        this.$message.error('上传文件只能是 XLSX / XLS 格式!');
                        return false;
                    }
                }
                return true;
            },
            // 文件上传中处理
            handleFileUploadProgress(event, file, fileList) {
                this.upload.isUploading = true;
            },
            // 文件上传成功处理
            handleFileSuccess(response, file, fileList) {
                var _this = this;
                this.upload.open = false; //关闭文件上传对话框
                this.upload.isUploading = false; //禁用文件上传
                this.$refs.upload.clearFiles(); //清空文件列表
                if (this.pageNo == '1-1') {
                    //提示导入结果
                    this.$alert(response, "导入结果", {
                        confirmButtonText: '确定',
                        callback: action => { //点击确定后刷新页面
                            _this.getSchemeInfo(0);
                        }
                    });
                } else {
                    sessionStorage.setItem('jsontreelist', response);
                    window.open("http://localhost:2008/SEClassDesign/resultManagePage.jsp");
                }

            },
            // 提交上传文件
            submitImportCourse() {
                this.$refs.upload.submit(); //提交到后台
            },
            // 取消上传
            cancelUploadFile() {
                this.upload.open = false; //关闭上传对话框
                this.$refs.upload.clearFiles(); //清空文件列表
            }
        }
    })
</script>

</html>