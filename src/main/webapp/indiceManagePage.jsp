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
                            <template slot="title"><i class="el-icon-setting"></i>算子管理</template>
                            <el-menu-item index="2-1">用户所有算子</el-menu-item>
                        </el-submenu>
                        <el-submenu index="3">
                            <template slot="title"><i class="el-icon-document"></i>运行记录</template>
                            <el-menu-item index="3-1">所有运行结果</el-menu-item>
                        </el-submenu>
                    </el-menu>
                </el-aside>
                <!-- 右半边 -->
                <el-container>
                    <!-- 头 -->
                    <el-header style="font-size: 12px;">
                        <!-- 创建新体系的按钮 -->
                        <el-button v-if="pageNo == '1-1'" type="primary" icon="el-icon-edit" style="margin-top: 10px"
                            @click="createNewScheme" plain>
                            创建新体系</el-button>
                        <el-button v-if="pageNo == '1-1'" type="primary" icon="el-icon-edit" style="margin-top: 10px"
                            @click="importSchemeTree" plain>
                            导入体系树</el-button>
                        <!-- 算子管理的按钮 -->
                        <el-button v-if="pageNo == '2-1'" type="primary" icon="el-icon-edit" style="margin-top: 10px"
                            @click="clickAddUserOpBtn" plain>
                            增加算子</el-button>
                        <el-button v-if="pageNo == '2-1'" type="primary" icon="el-icon-delete" style="margin-top: 10px"
                            @click="deleteOperators" plain>
                            删除所选算子</el-button>
                        <!-- 增加算子 -->
                        <el-dialog title="增加算子" :visible.sync="addUserOpDialogVisible" width="25%" center>
                            <div style="height: 250px; overflow: auto; text-align: center;">
                                <el-checkbox-group v-model="selectedAddOperators">
                                    <div v-for="operator in userNotHaveOperators" :key="operator.operator_id"
                                        style="margin-bottom: 20px;">
                                        <el-checkbox :label="operator.operator_id" border>
                                            {{ operator.operator_description }}
                                        </el-checkbox>
                                    </div>
                                    <!--
                                <el-checkbox v-for="operator in userNotHaveOperators" :label="operator.operator_id"
                                    :key="operator.operator_id">
                                    {{operator.operator_description}}</el-checkbox>
                                -->
                                </el-checkbox-group>
                            </div>
                            <span slot="footer" class="dialog-footer">
                                <el-button type="primary" @click="addOperators"
                                    style="margin-left: 30px; margin-right: 30px">增加
                                </el-button>
                                <el-button
                                    @click="addUserOpDialogVisible = false; selectedAddOperators=[];">取消</el-button>
                            </span>
                        </el-dialog>
                        <!-- 导入体系树，xml文件 -->
                        <el-dialog :title="upload.title" :visible.sync="upload.open" width="400px" append-to-body>
                            <el-upload ref="upload" :limit="1" accept="upload.accept" :action="upload.url"
                                :data="upload.additionalData" :disabled="upload.isUploading" name="treeFile"
                                :before-upload="beforeAvatarUpload" :on-progress="handleFileUploadProgress"
                                :on-success="handleFileSuccess" :auto-upload="false" drag>
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
                        <el-table height="66vh" key="templates"
                            :data="templateTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
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
                            <el-table :data="singleSchemeDetailInfo" key="templateIndices" height="90%">
                                <el-table-column type="index" align="center"></el-table-column>
                                <el-table-column prop="indice_id" label="指标id" align="center">
                                </el-table-column>
                                <el-table-column prop="indice_name" label="指标名称" align="center">
                                    <template slot-scope="scope">{{ typeof(scope.row.indice_name) == 'undefined' ? '无' :
                                        scope.row.indice_name }}</template>
                                </el-table-column>
                                <el-table-column prop="father_id" label="父节点id" align="center">
                                    <template slot-scope="scope">{{ typeof(scope.row.father_id) == 'undefined' ? '无' :
                                        scope.row.father_id }}</template>
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
                                    <el-form ref="addOrChangeIndiceForm" :model="indiceForm" label-width="25%">
                                        <el-form-item label="指标名称" prop="indice_name" style="width: 90%">
                                            <el-input v-model="indiceForm.indice_name"></el-input>
                                        </el-form-item>
                                        <el-form-item label="父节点id" prop="father_id" style="width: 90%">
                                            <el-select v-model="indiceForm.father_id" placeholder="请选择父节点"
                                                :disabled="indiceForm.father_id == -1 ? true : false"
                                                style="width: 100%">
                                                <el-option v-for="item in singleSchemeDetailInfo"
                                                    :label="item.indice_id" :value="item.indice_id"
                                                    :key="item.indice_id">
                                                </el-option>
                                            </el-select>
                                        </el-form-item>
                                        <el-form-item label="所属体系id" prop="scheme_id" style="width: 90%">
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
                        <el-table height="66vh" key="instance"
                            :data="instanceTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
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
                            <el-table :data="singleSchemeDetailInfo" key="instanceIndices" height="90%">
                                <el-table-column type="index" align="center"></el-table-column>
                                <el-table-column prop="indice_id" label="指标id" align="center">
                                </el-table-column>
                                <el-table-column prop="indice_name" label="指标名称" align="center">
                                    <template slot-scope="scope">{{ typeof(scope.row.indice_name) == 'undefined' ? '无' :
                                        scope.row.indice_name }}</template>
                                </el-table-column>
                                <el-table-column prop="indice_weight" label="指标权重" align="center">
                                    <template slot-scope="scope">{{ typeof(scope.row.indice_weight) == 'undefined' ? '无'
                                        : scope.row.indice_weight / 100 }}</template>
                                </el-table-column>
                                <el-table-column prop="father_id" label="父节点id" align="center">
                                    <template slot-scope="scope">{{ typeof(scope.row.father_id) == 'undefined' ? '无' :
                                        scope.row.father_id }}</template>
                                </el-table-column>
                                <el-table-column prop="operator_id" label="算子" :formatter="formatOperator"
                                    align="center">
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
                                    <el-form ref="addOrChangeIndiceForm" :model="indiceForm" label-width="25%">
                                        <el-form-item label="指标名称" prop="indice_name" style="width: 90%">
                                            <el-input v-model="indiceForm.indice_name"></el-input>
                                        </el-form-item>
                                        <el-form-item label="指标权重" prop="indice_weight" style="width: 90%">
                                            <el-slider v-model="indiceForm.indice_weight"
                                                :format-tooltip="formatTooltip">
                                            </el-slider>
                                        </el-form-item>
                                        <el-form-item label="父节点id" prop="father_id" style="width: 90%">
                                            <el-select v-model="indiceForm.father_id" placeholder="请选择父节点"
                                                :disabled="indiceForm.father_id == -1 ? true : false"
                                                style="width: 100%">
                                                <el-option v-for="item in singleSchemeDetailInfo"
                                                    :label="item.indice_id" :value="item.indice_id"
                                                    :key="item.indice_id">
                                                </el-option>
                                            </el-select>
                                        </el-form-item>
                                        <el-form-item label="算子" prop="operator_id" style="width: 90%">
                                            <el-select v-model="indiceForm.operator_id" placeholder="请选择算子"
                                                style="width: 100%">
                                                <el-option v-for="item in userOperators"
                                                    :label="item.operator_description" :value="item.operator_id"
                                                    :key="item.operator_id">
                                                </el-option>
                                            </el-select>
                                        </el-form-item>
                                        <el-form-item label="所属体系id" prop="scheme_id" style="width: 90%">
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
                    <!-- 算子管理模块 -->
                    <el-main v-else-if="pageNo=='2-1'">
                        <el-table ref="multipleTable" height="66vh" key="operators"
                            :data="userOperators.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)"
                            tooltip-effect="dark" @selection-change="handleSelectionChange">
                            <el-table-column type="selection" width="200px">
                            </el-table-column>
                            <el-table-column type="index" width="200px">
                            </el-table-column>
                            <el-table-column prop="operator_description" label="算子信息" align="center">
                            </el-table-column>
                            <el-table-column label="算子描述" :formatter="opContentFormatter" align="center">
                            </el-table-column>
                        </el-table>
                        <div style="margin-top: 20px">
                            <el-button @click="toggleSelection(1)">全选</el-button>
                            <el-button @click="toggleSelection(0)">取消选择</el-button>
                        </div>
                    </el-main>
                    <!-- 运算结果 -->
                    <el-main v-else>
                        <!-- 显示所有体系信息 -->
                        <el-table height="76vh"
                            :data="resTableData.slice((page.currentPage-1)*page.pageSize, page.currentPage*page.pageSize)">
                            <template>
                                <el-table-column label="序号" type="index" align="center"></el-table-column>
                                <el-table-column align="center" v-for="(column, columnIndex) in resTableData[0]"
                                    :key="columnIndex" :label="resTableData[0][columnIndex].indice_name">
                                    <template slot-scope="scope">
                                        {{resTableData.slice((page.currentPage-1)*page.pageSize,
                                        page.currentPage*page.pageSize)[scope.$index][columnIndex].indice_value}}
                                    </template>
                                </el-table-column>
                            </template>
                        </el-table>
                    </el-main>
                    <!--分页工具条-->
                    <el-footer>
                        <div class="block">
                            <el-pagination @current-change="handleCurrentChange" :current-page="page.currentPage"
                                :page-size="page.pageSize" layout="total, prev, pager, next, jumper"
                                :total="page.total">
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
                    //要查看记录的体系的id
                    schemeIDForResult: '',
                    //体系下所有运行的时间
                    resultTimes: [],
                    //运行的时间
                    execTimeForResult: '',
                    //获取结果数据
                    resTableData: [],
                    //所有的算子
                    operators: [],
                    // 用户的所有算子
                    userOperators: [],
                    // 用户没有的算子
                    userNotHaveOperators: [],
                    //增加算子的对话框是否显示
                    addUserOpDialogVisible: false,
                    //要增加的算子的id
                    selectedAddOperators: [],
                    //记录多选表格的选中行,用于删除算子
                    multipleSelection: [],
                    //表格用的体系信息
                    templateTableData: [],
                    //实例信息
                    instanceTableData: [],
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
                        //分页展示，每页8条
                        pageSize: 8,
                        //总条数
                        total: 0
                    }
                }
            },
            mounted() { //HTML页面渲染成功，就获取所有用户的信息    
                this.currentUser = ${ sessionScope.currentUser }; //从session中获取当前正在登录的对象
                this.uploadAdditionalData = {
                    user_id: this.currentUser.user_id
                }; //上传文件时附带的数据
                this.getSchemeInfo(0); //获取体系模板信息
                this.getSchemeInfo(1); //获取体系实例信息
                this.getAllOperator(); //获取所有的算子
                this.getUserOperators(); //获取用户拥有的算子信息
                this.getUserNotHaveOperators(); //获取用户没有的算子信息
            },
            methods: {
                //页面切换
                switchPage(index) {
                    this.pageNo = index;
                    this.resTableData = [];
                    if (index == '1-1') { //所有的体系模板
                        this.getSchemeInfo(0);
                        this.page.currentPage = 1;
                    } else if (index == '1-2') { //所有的体系实例
                        this.getSchemeInfo(1);
                        this.page.currentPage = 1;
                    } else if (index == '2-1') {
                        this.getUserOperators(); //获取用户拥有的算子信息
                        this.getUserNotHaveOperators(); //获取用户没有的算子信息
                        this.page.currentPage = 1;
                    } else {
                        this.getSchemeInfo(1); //获取所有体系实例信息
                        this.getSchemeIdForResult();//获取计算结果
                    }
                },
                //根据体系id和时间获取运行结果
                getResult() {
                    var _this = this;
                    axios({
                        method: 'get',
                        url: _this.urlHeader + 'request=getResult&scheme_id=' + _this.schemeIDForResult + '&exec_time=' + _this.execTimeForResult
                    }).then(function (resp) {
                        console.log('获取到了所有时间信息:\n' + resp.data);
                        //_this.resultTableData = resp.data;
                        let temp = resp.data;
                        var list = [];
                        for (var i of temp) {
                            var indicelist = [];
                            for (var j of JSON.parse(i)) {
                                indicelist.push(JSON.parse(j));
                            }
                            list.push(indicelist);
                        }
                        _this.resTableData = list;
                        _this.page.currentPage = 1;
                        _this.page.total = _this.resTableData.length;
                    })
                },
                //获取所有的运行时间
                getAllResultTimeOfScheme() {
                    var _this = this;
                    axios({
                        method: 'get',
                        url: _this.urlHeader + 'request=getAllResultTime&scheme_id=' + _this.schemeIDForResult
                    }).then(function (resp) {
                        console.log('获取到了所有时间信息:\n' + resp.data);
                        _this.resultTimes = resp.data;
                        _this.selectExecTime();
                    })
                },
                //选择运行时间
                selectExecTime() {
                    const h = this.$createElement;
                    var _this = this;
                    this.$msgbox({
                        title: '请选择运行的时间', //弹框标题
                        //弹框信息
                        message: h('el-select', {
                            props: {
                                value: '',
                                filterable: true
                            },
                            ref: 'selectExecTimeView',
                            on: {
                                change: e => {
                                    _this.execTimeForResult = e;
                                    _this.$refs.selectExecTimeView.value = e;
                                }
                            }
                        },
                            [
                                _this.resultTimes.map(it => {
                                    return h('el-option', {
                                        props: {
                                            key: it,
                                            label: it,
                                            value: it
                                        }
                                    });
                                })
                            ]
                        ),
                        showCancelButton: true,
                        closeOnClickModal: false,
                        confirmButtonText: '确定',
                        cancelButtonText: '取消'
                    }).then(_ => {
                        //成功操作
                        console.log('点击确定，运行时间=' + _this.execTimeForResult);
                        //获取运算结果
                        this.getResult();
                    }).catch(_ => {
                        //取消操作
                        console.log('取消');
                        this.$message({
                            message: '取消查询',
                            type: 'warning'
                        });
                        _this.execTimeForResult = '';
                    });
                },
                //选择要查询哪一个体系的运行记录
                getSchemeIdForResult() {
                    const h = this.$createElement;
                    var _this = this;
                    this.$msgbox({
                        title: '请选择要查看运行记录的体系', //弹框标题
                        //弹框信息
                        message: h('el-select', {
                            props: {
                                value: '',
                                filterable: true
                            },
                            ref: 'selectView',
                            on: {
                                change: e => {
                                    _this.schemeIDForResult = e;
                                    _this.$refs.selectView.value = e;
                                }
                            }
                        },
                            [
                                _this.instanceTableData.map(it => {
                                    return h('el-option', {
                                        props: {
                                            key: it.scheme_id,
                                            label: it.scheme_name,
                                            value: it.scheme_id
                                        }
                                    });
                                })
                            ]
                        ),
                        showCancelButton: true,
                        closeOnClickModal: false,
                        confirmButtonText: '确定',
                        cancelButtonText: '取消'
                    }).then(_ => {
                        //成功操作
                        console.log('点击确定，查看体系scheme_id=' + _this.schemeIDForResult);
                        //根据id查询时间
                        this.getAllResultTimeOfScheme();
                    }).catch(_ => {
                        //取消操作
                        console.log('取消');
                        this.$message({
                            message: '取消查询',
                            type: 'warning'
                        });
                    });
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
                //获取用户的所有算子
                getUserOperators() {
                    console.log("获取用户所有算子信息");
                    var _this = this;
                    axios({
                        method: 'post',
                        url: _this.urlHeader + 'request=getUserOperators',
                        data: "user_id=" + _this.currentUser.user_id
                    }).then(function (resp) {
                        console.log('获取到了用户的所有算子信息:\n' + resp.data);
                        _this.userOperators = resp.data;
                        _this.page.total = _this.userOperators.length;
                    })
                },
                //获取用户没有的所有算子
                getUserNotHaveOperators() {
                    var _this = this;
                    axios({
                        method: 'post',
                        url: _this.urlHeader + 'request=getUserNotHaveOperators',
                        data: "user_id=" + _this.currentUser.user_id
                    }).then(function (resp) {
                        console.log('获取到了用户没有的所有算子信息:\n' + resp.data);
                        _this.userNotHaveOperators = resp.data;
                    })
                },
                clickAddUserOpBtn() {
                    if (this.userNotHaveOperators.length == 0) {
                        this.$message({
                            message: '您已配置所有算子',
                            type: 'success'
                        });
                    } else {
                        this.addUserOpDialogVisible = true;
                    }
                },
                //为用户增添算子
                addOperators() {
                    var _this = this;
                    var data = "user_id=" + this.currentUser.user_id + "&selectedAddOps=" + JSON.stringify(this
                        .selectedAddOperators); //把数组转换为JSON字符串
                    axios({
                        method: 'post',
                        url: _this.urlHeader + 'request=addUserOperators',
                        data: data
                    }).then(function (resp) {
                        console.log("获取到了……\n" + resp.data); //增加成功
                        if (resp.data > 0) {
                            //刷新页面
                            Vue.prototype.$message({
                                message: '增加了' + resp.data + '个算子！',
                                type: 'success'
                            });
                            _this.getUserOperators();
                            _this.getUserNotHaveOperators();
                            //关闭对话框
                            _this.addUserOpDialogVisible = false;
                            //清空列表
                            _this.selectedAddOperators = [];
                        } else {
                            this.$message.error('增加失败');
                        }
                    })
                },
                //删除算子
                deleteOperators() {
                    if (this.multipleSelection.length == 0) { //若是没有选中任何算子
                        Vue.prototype.$message({
                            type: 'warning',
                            message: '您尚未选中任何算子！'
                        });
                    } else {
                        Vue.prototype.$confirm('此操作将删除所选算子，是否删除？', '提示', {
                            confirmButtonText: '确定',
                            cancelButtonText: '取消',
                            type: 'warning',
                            cancelButtonClass: 'el-button--default el-button--small el-button--cancel'
                        }).then(() => { //点击了确定
                            //删除用户所选的算子
                            var _this = this;
                            var data = "user_id=" + this.currentUser.user_id + "&selectedDelOps=" + JSON
                                .stringify(this.multipleSelection); //把数组转换为JSON字符串
                            axios({
                                method: "post",
                                url: _this.urlHeader + "request=deleteUserOperators",
                                data: data
                            }).then(function (resp) {
                                console.log("获取到了……\n" + resp.data); //删除成功
                                if (resp.data > 0) {
                                    //刷新页面
                                    Vue.prototype.$message({
                                        message: '删除成功！',
                                        type: 'success'
                                    });
                                    //刷新页面
                                    _this.getUserOperators();
                                    _this.getUserNotHaveOperators();
                                    //取消选择
                                    _this.toggleSelection(0);
                                } else {
                                    this.$message.error('删除失败');
                                }
                            })
                        }).catch(() => { //点击了取消
                            Vue.prototype.$message({
                                type: 'info',
                                message: '已取消删除'
                            });
                        });
                    }
                },
                //当多选表格的选中状态改变时会调用这个函数
                toggleSelection(option) {
                    if (option == 1) { //全选
                        this.userOperators.forEach(row => {
                            //该方法用于多选表格，切换某一行的选中状态
                            this.$refs.multipleTable.toggleRowSelection(row, true); //如果设置了第二个参数则是设置这一行选中与否
                        });
                    } else { //取消选择
                        this.$refs.multipleTable.clearSelection();
                    }
                },
                //多选表单，选择状态变化时执行的操作
                handleSelectionChange(val) { //这个val是一个列表，记录了当前所有被选中的行的数据
                    this.multipleSelection = val;
                },
                //格式化算子描述内容
                opContentFormatter(row, column, cellValue, index) {
                    switch (row.operator_id) {
                        case 1:
                            return '相加';
                        case 2:
                            return '相减';
                        case 3:
                            return '相乘';
                        case 4:
                            return '相除';
                        case 5:
                            return '取最大值';
                        case 6:
                            return '取最小值';
                        case 7:
                            return '取平均值';
                        default:
                            return '错误的算子';
                    }
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
                        if (isInstance == 0) {
                            _this.templateTableData = resp.data;
                            _this.page.total = _this.templateTableData.length;
                        } else {
                            _this.instanceTableData = resp.data;
                            _this.page.total = _this.instanceTableData.length;
                        }

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
                        _this.templateTableData = resp.data;
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
                            _this.getSingleSchemeDetailInfo(_this.indiceForm.scheme_id); //刷新
                        } else if (resp.data == -1) {
                            _this.$message.error('失败！父节点不存在');
                        } else {
                            _this.$message.error('创建失败！');
                        }
                        _this.innerDrawerVisible = false; //关闭表单
                        _this.$refs.addOrChangeIndiceForm.resetFields(); //重置表单域
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
                            } else {
                                _this.$message.error('修改失败！');
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
                            console.log("resp.data" + resp.data); //创建成功
                            //打开体系树页面
                            if (resp.data > 0) {
                                Vue.prototype.$message({
                                    message: '创建体系实例成功！',
                                    type: 'success'
                                });
                                _this.getSchemeInfo(1);
                                _this.pageNo = '1-2';
                                _this.page.currentPage = 1;
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
                //格式化显示算子内容
                formatOperator(row, column, cellValue, index) {
                    if (typeof (row.operator_id) == 'undefined') {
                        return '无';
                    } else {
                        for (var operator of this.operators) {
                            if (operator.operator_id == row.operator_id) {
                                return operator.operator_description;
                            }
                        }
                        return '无';
                    }
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
                    var fileType2 = (file.type === 'application/vnd.ms-excel' || file.type ===
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                    if (this.pageNo == '1-1') {
                        if (!fileType1) {
                            this.$message.error('上传文件只能是 JSON / XML 格式!');
                            return false;
                        }

                    } else {
                        if (!fileType2) {
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
                        if (response == '-1') {
                            this.$message.error('文件解析失败，叶子结点个数或名称出错！');
                        } else {

                            //console.log('ssdjal','${requestScope.tableData}');
                            sessionStorage.setItem('jsontreelist', response);
                            //sessionStorage.setItem('tableData',);
                            window.open("http://localhost:2008/SEClassDesign/resultManagePage.jsp");
                        }
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