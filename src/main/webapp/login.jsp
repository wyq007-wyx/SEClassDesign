<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>请登录</title>
    <link href="./css/login.css" rel="stylesheet">
    <!-- 在线引入最新样式 -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
</head>

<body>
    <div id="app">
        <div class="form-div">
            <div class="reg-content">
                <h1>欢迎登录</h1>
                <p>没有帐号？<el-button id="regBtn" @click="registerDialogVisible = true" plain>注册</el-button>
                </p>
                <p>忘记密码？<el-button id="resetBtn" @click="clickReset" plain>重置</el-button>
                </p>
            </div>
            <form id="reg-form" action="GetLogin.do" method="post">
                <table>
                    <tr>
                        <td>用户名</td>
                        <td class="inputs"><input name="username" type="text" id="username"><br></td>
                    </tr>
                    <tr>
                        <td>密码</td>
                        <td class="inputs"><input name="password" type="password" id="password"><br></td>
                    </tr>
                </table>
                <div class="buttons">
                    <input value="登 录" type="submit" id="login_btn"><br>
                    <input value="清 空" type="reset" id="clear_btn"><br>
                </div>
                <br class="clear">
            </form>
        </div>
        <!-- 注册账户的对话框 -->
        <el-dialog title="注册账户" :visible.sync="registerDialogVisible" width="30%" center>
            <div style="height: 210px; overflow: auto">
                <el-form ref="registerForm" :model="registerForm" label-width="80px" :rules="userRule">
                    <el-form-item label="用户名" prop="username">
                        <el-input v-model="registerForm.username"></el-input>
                    </el-form-item>
                    <el-form-item label="密码" prop="password">
                        <el-input v-model="registerForm.password" show-password></el-input>
                    </el-form-item>
                    <el-form-item label="邮箱地址" prop="email">
                        <el-input v-model="registerForm.email"><template slot="append">.com</template>
                        </el-input>
                    </el-form-item>
                </el-form>
            </div>
            <span slot="footer" class="dialog-footer">
                <el-button type="primary" @click="submitForm('registerForm')"
                    style="margin-left: 30px; margin-right: 30px">注册
                </el-button>
                <el-button @click="cancelSubmit('registerForm')">取消</el-button>
            </span>
        </el-dialog>
        <!-- 录入问题的对话框 -->
        <el-dialog title="重置密码的问题" :visible.sync="questionDialogVisible" width="30%" center>
            <div>
                <el-form :model="questionForm" label-width="80px">
                    <el-form-item label="用户ID">
                        <el-input v-model="questionForm.user_id" disabled></el-input>
                    </el-form-item>
                    <el-form-item label="问题1" required>
                        <el-select v-model="questionForm.question1">
                            <el-option label="您的父亲的姓名是？" value="您的父亲的姓名是？"></el-option>
                            <el-option label="您的母亲的姓名是？" value="您的母亲的姓名是？"></el-option>
                            <el-option label="您的爱人的姓名是？" value="您的爱人的姓名是？"></el-option>
                            <el-option label="您的孩子的姓名是？" value="您的孩子的姓名是？"></el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="答案1" required>
                        <el-input type="textarea" autosize placeholder="请输入问题1的答案" v-model="questionForm.answer1">
                        </el-input>
                    </el-form-item>
                    <el-form-item label="问题2" required>
                        <el-select v-model="questionForm.question2">
                            <el-option label="您上的小学是？" value="您上的小学是？"></el-option>
                            <el-option label="您上的初中是？" value="您上的初中是？"></el-option>
                            <el-option label="您上的高中是？" value="您上的高中是？"></el-option>
                            <el-option label="您上的大学是？" value="您上的大学是？"></el-option>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="答案2" required>
                        <el-input type="textarea" autosize placeholder="请输入问题2的答案" v-model="questionForm.answer2">
                        </el-input>
                    </el-form-item>
                </el-form>
            </div>
            <span slot="footer" class="dialog-footer">
                <el-button type="primary" @click="submitQuestion" style="margin-left: 30px; margin-right: 30px">确认
                </el-button>
                <el-button @click="questionDialogVisible = false">取消</el-button>
            </span>
        </el-dialog>
        <!--重置密码的回答问题的对话框-->
        <el-dialog title="重置密码" :visible.sync="answerDialogVisible" width="30%" center>
            <div>
                <el-form ref="form" :model="questionInfo" label-width="80px">
                    <el-form-item label="问题1">
                        <el-input v-model="questionInfo.question1" disabled></el-input>
                    </el-form-item>
                    <el-form-item label="答案1" required>
                        <el-input type="textarea" autosize placeholder="请输入问题1的答案" v-model="answer1">
                        </el-input>
                    </el-form-item>
                    <el-form-item label="问题2">
                        <el-input v-model="questionInfo.question2" disabled></el-input>
                    </el-form-item>
                    <el-form-item label="答案2" required>
                        <el-input type="textarea" autosize placeholder="请输入问题2的答案" v-model="answer2">
                        </el-input>
                    </el-form-item>
                </el-form>
            </div>
            <span slot="footer" class="dialog-footer">
                <el-button type="primary" @click="judgeAnswer" style="margin-left: 30px; margin-right: 30px">确认
                </el-button>
                <el-button @click="answerDialogVisible = false">取消</el-button>
            </span>
        </el-dialog>
        <!-- 重置密码的对话框 -->
        <el-dialog title="重置密码" :visible.sync="resetDialogVisible" width="30%" center>
            <div>
                <el-form ref="ruleForm" :model="resetForm" status-icon :rules="passwordRules" label-width="80px"
                    class="demo-ruleForm">
                    <el-form-item label="用户ID">
                        <el-input v-model="resetForm.user_id" disabled></el-input>
                    </el-form-item>
                    <el-form-item label="密码" prop="password">
                        <el-input type="password" v-model="resetForm.password" autocomplete="off"></el-input>
                    </el-form-item>
                    <el-form-item label="确认密码" prop="checkPassword">
                        <el-input type="password" v-model="resetForm.checkPassword" autocomplete="off"></el-input>
                    </el-form-item>
                </el-form>
            </div>
            <span slot="footer" class="dialog-footer">
                <el-button type="primary" @click="submitForm('ruleForm')" style="margin-left: 30px; margin-right: 30px">
                    重置
                </el-button>
                <el-button @click="resetDialogVisible = false">取消</el-button>
            </span>
        </el-dialog>
    </div>
    <script src="js/axios-0.18.0.js"></script>
    <!-- import Vue before Element -->
    <!-- <script src="js/vue.js"></script> -->
    <script src="https://unpkg.com/vue@2/dist/vue.js"></script>
    <!-- import JavaScript -->
    <script src="https://unpkg.com/element-ui/lib/index.js"></script>
    <script>
        import Vue from 'vue';
    </script>
    <script>
        new Vue({
            el: '#app',
            data() {
                var validatePass = (rule, value, callback) => {
                    if (value === '') {
                        callback(new Error('请输入密码'));
                    } else {
                        if (this.resetForm.checkPassword !== '') {
                            this.$refs.ruleForm.validateField('checkPassword');
                        }
                        callback();
                    }
                };
                var validatePass2 = (rule, value, callback) => {
                    if (value === '') {
                        callback(new Error('请再次输入密码'));
                    } else if (value !== this.resetForm.password) {
                        callback(new Error('两次输入密码不一致!'));
                    } else {
                        callback();
                    }
                };
                return {
                    //校验规则
                    passwordRules: {
                        password: [{
                            validator: validatePass,
                            trigger: 'blur'
                        }],
                        checkPassword: [{
                            validator: validatePass2,
                            trigger: 'blur'
                        }]
                    },
                    userRule: {
                        username: {
                            type: "string",
                            required: true,
                            message: '请输入用户名',
                            trigger: 'blur'
                        },
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
                    urlHeader: 'http://localhost:2008/SEClassDesign/',
                    //注册账户的对话框是否可见
                    registerDialogVisible: false,
                    //注册账户的表单
                    registerForm: {},
                    //重置密码的问题的对话框
                    questionDialogVisible: false,
                    //重置密码的问题的表单
                    questionForm: {},
                    //重置密码的问题信息
                    questionInfo: {},
                    //重置密码回答问题对话框是否可见
                    answerDialogVisible: false,
                    //问题1的答案
                    answer1: '',
                    //问题2的答案
                    answer2: '',
                    //重置密码的对话框是否可见
                    resetDialogVisible: false,
                    //重置密码的表单
                    resetForm: {
                        user_id: '',
                        password: '',
                        checkPassword: ''
                    }
                }
            },
            methods: {
                //注册
                register() {
                    var _this = this;
                    //向后端发送异步请求
                    axios({
                        method: "post",
                        url: _this.urlHeader + 'GetRegister.do',
                        data: _this.registerForm
                    }).then(function (resp) {
                        if (resp.data >= 1) { //注册成功
                            Vue.prototype.$message({
                                message: '注册成功！',
                                type: 'success'
                            });
                            _this.registerForm = {}; //清空表单
                            _this.registerDialogVisible = false; //关闭对话框
                            _this.questionForm.user_id = resp.data; //获取回填的user_id
                            _this.questionDialogVisible = true; //显示重置密码录入信息的对话框
                        } else if (resp.data == -1) {
                            Vue.prototype.$message.error('发生重名，请重新输入信息！');
                            _this.registerForm.username = ''; //清空用户名的输入
                        } else {
                            Vue.prototype.$message.error('注册失败！');
                            _this.registerForm = {}; //清空表单
                            _this.registerDialogVisible = false; //关闭对话框
                        }
                    })
                },
                //重置密码的对话框中点击确认
                submitQuestion() {
                    var _this = this;
                    axios({
                        method: 'post',
                        url: _this.urlHeader + 'GetQuestion.do',
                        data: _this.questionForm
                    }).then(function (resp) {
                        _this.questionDialogVisible = false; //关闭对话框
                        if (resp.data == 1) { //注册成功
                            Vue.prototype.$message({
                                message: '重置密码问题信息录入成功！',
                                type: 'success'
                            });
                            _this.questionForm = {};//清空表单
                        } else {
                            Vue.prototype.$message.error('录入失败！');
                        }
                    })
                },
                //点击重置密码的请求
                clickReset() {
                    //请求用户输入用户名
                    var _this = this;
                    let username = document.getElementById('username').value;
                    //需要用户输入用户名
                    if (username == '') {
                        this.$prompt('请输入用户名', '错误', {
                            confirmButtonText: '确定',
                            cancelButtonText: '取消'
                        }).then(({value}) => {
                            _this.getQuestionInfo(value); //向后端请求重置密码的问题信息
                        }).catch(() => {
                            this.$message({
                                type: 'info',
                                message: '取消输入'
                            });
                        });
                    } else {
                        _this.getQuestionInfo(username); //向后端请求重置密码的问题信息
                    }

                },
                //向后端请求重置密码的问题信息
                getQuestionInfo(username) {
                    var _this = this;
                    axios({
                        method: 'post',
                        url: _this.urlHeader + 'RequestForQuestionInfo.do',
                        data: 'username=' + username
                    }).then(function (resp) {
                        if (resp.data == 'null') {
                            Vue.prototype.$message.error('没有查询到重置密码的问题信息，请联系管理员！');
                        } else {
                            _this.questionInfo = resp.data; //获取到重置密码的问题信息
                            //清空答案1 2的值
                            _this.answer1 = '';
                            _this.answer2 = '';
                            _this.answerDialogVisible = true; //显示重置密码回答问题对话框
                        }
                    })
                },
                //点击确定判断答案是否正确
                judgeAnswer() {
                    //答案正确，可以重置密码
                    if (this.answer1 == this.questionInfo.answer1 && this.answer2 == this.questionInfo
                        .answer2) {
                        this.answerDialogVisible = false; //关闭回答问题的对话框
                        this.resetForm.user_id = this.questionInfo.user_id; //为重置密码对话框赋值
                        this.resetDialogVisible = true; //显示重置密码的对话框
                    } else {
                        Vue.prototype.$message.error('答案错误！');
                        //清空答案1 2的值
                        this.answer1 = '';
                        this.answer2 = '';
                    }
                },
                //提交表单
                submitForm(formName) {
                    var _this = this;
                    this.$refs[formName].validate((valid) => {
                        if (valid) {
                            if (formName == 'registerForm') {
                                _this.register();
                            } else {
                                _this.resetPassword(); //向后端重置密码
                            }
                        } else {
                        	Vue.prototype.$message.error('请检查表单是否填写完整！');
                            console.log('提交错误!!');
                            return false;
                        }
                    });
                },
                //取消提交表单
                cancelSubmit(formName) {
                    //重置表单和验证结果
                    if (formName == 'registerForm') {
                        this.$refs.registerForm.resetFields();
                        this.registerDialogVisible = false; //关闭对话框
                    } 
                },
                //重置密码
                resetPassword() {
                    var _this = this;
                    axios({
                        method: 'post',
                        url: _this.urlHeader + 'ResetPassword.do',
                        data: 'user_id=' + _this.resetForm.user_id + '&password=' + _this.resetForm
                            .password
                    }).then(function (resp) {
                        if (resp.data == 1) {
                            Vue.prototype.$message({
                                message: '重置密码成功，您可以重新登录了！',
                                type: 'success'
                            });
                            _this.resetDialogVisible = false; //关闭重置密码的对话框
                        } else {
                            Vue.prototype.$message.error('重置密码失败！');
                        }
                    })
                }
            }
        })
    </script>
</body>

</html>