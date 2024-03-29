      
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <title>Echarts 树形图示例</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport' />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <!-- <link href='./bootstrap/css/bootstrap.css' media='all' rel='stylesheet' type='text/css' /> -->
    <!-- <link rel="stylesheet" href="./css/element-ui/lib/theme-chalk/index.css"> -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
    <style>
        * {
            padding: 0;
            margin: 0;
        }
        .menu {
            /*这个样式不写，右键弹框会一直显示在画布的左下角*/
            position: absolute;
            background: #ffff;
            border-radius: 5px;
            left: -99999px;
            top: -999999px;
            z-index: 1;
        }

        .menu ul {
            list-style: none
        }

        .menu ul li {
            padding: 5px 10px;
            color: #228EFB;
            border-bottom: 1px dashed #228EFB;
            font-size: 17px;
        }

        .menu ul li:last-child {
            border-bottom: none;
        }

        .el-button--cancel {
            order: 2;
            margin-left: 10px;
            float: right;
        }
    </style>
</head>

<body class='contrast-blue'>
    <div id="app">
        <div style="background-color: rgb(16,12,42); height: 15vh; " >
            <el-button type="primary" style="margin: 10px 10px 10px 10px; float: right; width: 150px;"
                @click="backToIndiceManagePage" plain>
                退出</el-button>
            <el-button type="primary" icon="el-icon-edit" style="margin: 10px 0 10px 10px; float: right; width: 150px;"
                @click="clickExportSchemeJSON" plain>
                导出JSON</el-button>
            <el-button type="primary" icon="el-icon-edit" style="margin: 10px 0 10px 0; float: right; width: 150px;"
                @click="clickExportSchemeImg" plain>
                导出图片</el-button>
        </div>
        <!-- 树模块 -->
        <div id='wrapper' >
            <section id='content'>
                <div class="tree-container">
                    <div id="main" style="width:100%; height: 85vh;"></div>
                </div>
            </section>
        </div>
        <!--右键弹出菜单-->
        <div id="rightMenu" class="menu" style="display:none;">
            <el-button v-if="isInstance == 0 ? false : true" style="width:150px" @click="editCurrentNode">编辑当前节点</el-button> 
            <br v-if="isInstance == 0 ? false : true"/>
            <el-button style="width:150px" @click="addChildNode">增加子节点</el-button><br/>
            <el-button style="width:150px" @click="deleteCurrentNode">删除当前节点</el-button>
        </div>

        <!-- 编辑节点窗口 -->
        <el-dialog id="editNodeDialog" width="400px" title="编辑指标" :visible.sync="editDialogVisible" center>
            <el-form ref="nodeform" :model="currentNode" :rules="nodeRule" label-width="80px"
                style="height: 300px;overflow-y: auto;">
                <el-form-item label="指标id" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_id" disabled></el-input>
                </el-form-item>
                <el-form-item label="指标名" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_name"></el-input>
                </el-form-item>
                <el-form-item label="指标权重" style="width:310px">
                    <el-slider v-model="currentNode.indice.indice_weight"
                        :format-tooltip="formatTooltip"></el-slider>
                    <!-- <el-input v-model="currentNode.indice.indice_weight"></el-input> -->
                </el-form-item>
                <el-form-item label="指标值" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_value" disabled></el-input>
                </el-form-item>
                <el-form-item label="父节点id" style="width:310px">
                    <el-input v-model="currentNode.indice.father_id" disabled></el-input>
                </el-form-item>
                <el-form-item label="算子" style="width:310px">
                    <el-select v-model="currentNode.indice.operator_id" placeholder="选择算子">
                        <el-option v-for="item in ops" :label="item.operator_description" :value="item.operator_id"
                            :key="item.operator_id">
                        </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="系统id" style="width:310px">
                    <el-input v-model="currentNode.indice.scheme_id" disabled></el-input>
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="cancelEditNode()">取 消</el-button>
                <el-button type="primary" @click="submitNode()">确 定</el-button>
            </div>
        </el-dialog>
    </div>
</body>
<!--资源引入-->
<script src="js/axios-0.18.0.js"></script>
<script src='./js/jquery.min.js' type='text/javascript'></script>
<script src="https://unpkg.com/vue@2/dist/vue.js"></script>
<!-- <script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.js"></script> -->
<script src="./js/echarts.js"></script>
<script src="https://unpkg.com/element-ui/lib/index.js"></script>
<!----------->
<script type="text/javascript">
    new Vue({
        el: '#app',
        data() {
            return {
                //当前体系id
                scheme_id: ${ param.scheme_id },
                scheme_name: '',
                isInstance: 0,
                //所有算子
                ops: [
                    {
                        operator_id: '',
                        operator_description: ''
                    }
                ],
                //编辑窗口是否可见
                editDialogVisible: false,
                nodeRule: {
                    operator_id: [
                        {
                            required: true,
                            message: '请选择算子'
                        }
                    ]
                },
                //当前节点
                currentNode: {
                    name: '',
                    indice: {
                        indice_id: '',
                        indice_name: '',
                        indice_weight: 0,
                        indice_value: '',
                        father_id: '',
                        operator_id: null,
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
                urlHeader: 'http://localhost:2008/SEClassDesign/',
            }
        },
        methods: {
            //初始加载树结构
            loadTreeStruct() {
                var jsontree = ${ requestScope.jsontree};
                this.tree_struct = jsontree;
                //console.log(jsontree);
                this.drawTree();
            },
            //重新渲染树结构
            drawTree() {
                var data = this.tree_struct;
                console.log(this.tree_struct);
                var chartDom = document.getElementById('main');
                var myChart = echarts.init(chartDom, 'dark');
                var option;
                myChart.showLoading();//echarts自带的Loading遮罩方法
                myChart.hideLoading();
                // data.collapsed = false;
                // data.children.forEach(function (datum, index) {
                //     datum.collapsed = false;
                // });
                option = {
                    tooltip: {
                        show: true,
                        trigger: 'item',
                        triggerOn: 'mousemove',
                        position: "bottom",
                        textStyle: {
                            color: "#228EFB",
                            fontSize: 17
                        },
                        extraCssText: 'width:300px;white-space:pre-wrap;',
                        formatter: function (params, ticket, callback) {
                            var tsxx = params.data.describes == "" || params.data.describes == null ? params.data.name : params.data.describes;
                            return tsxx;
                        }
                    },
                    series: [
                        {
                            type: 'tree',
                            data: [data],
                            top: 'middle',
                            left: 'center',
                            // bottom: '1%',
                            // right: '15%',
                            symbolSize: 15,
                            itemStyle: {
                                color: '#228EFB',
                            },
                            lineStyle: {
                                color: '#DDD',
                            },
                            label: {
                                color: "#FFF",
                                position: 'left',
                                verticalAlign: 'middle',
                                align: 'right',
                                fontSize: 18
                            },
                            leaves: {
                                label: {
                                    position: 'right',
                                    verticalAlign: 'middle',
                                    align: 'left'
                                }
                            },
                            emphasis: {
                                focus: 'descendant'
                            },
                            edgeForkPosition: "72%",
                            roam: true,//鼠标缩放，拖拽整颗树
                            expandAndCollapse: true,
                            animationDuration: 550,
                            animationDurationUpdate: 750
                        }
                    ]
                };
                myChart.clear();
                myChart.setOption(option);
                myChart.on("click", this.treeNodeclick);    //节点点击事件
                /**
                * 鼠标右键，弹出右键操作菜单
                */
                $("#main").bind("contextmenu", function () { return false; });//防止默认菜单弹出（查看图像,图像另存为等）
                var gloab_param = null;
                var _this = this;
                var yOffset = this.isInstance == 0 ? -20 : 20;
                myChart.on("contextmenu", function (params) {
                console.log(yOffset);
                gloab_param = params;
                $('#rightMenu').css({
                    'display': 'block',
                    'left': params.event.offsetX + 10,//此处根据自己实际情况调整右键操作菜单显示位置
                    'top': params.event.offsetY - yOffset
                });
                 _this.currentNode = params.data;
                });
                /**
                 * 点击画布的时候隐藏右键菜单
                 */
                $('.tree-container').click(function () {
                    $('#rightMenu').css({
                        'display': 'none',
                        'left': '-9999px',
                        'top': '-9999px'
                    });
                });

            },
            //节点点击
            treeNodeclick(param) {
                /* true 代表点击的是圆点
                   false 表示点击的是当前节点的文本
                */
                if(param.event.target.culling === true) {
                    if (typeof param.seriesIndex == 'undefined') {
                        return;
                    }
                    if (param.type == 'click') {
                        if (!param.data.hasChild) {
                            if (param.data.collapsed == undefined || param.data.collapsed == true) {
                                //console.log("未定义或者是未展开，下次即将展开");
                                param.data.collapsed = false;
                            }
                            else {
                                //console.log("下次不展开");
                                param.data.collapsed = true;
                                this.collapseTreeNode(param.data);
                            }
                            return;
                        } else { }
                    }
                    return;
                } 
                else if (param.event.target.culling === false) {
                    // 	        let args = param.data; //当前节点及其子节点的值
                    // 	        let level = param.data.level; //当前节点的层级 eg:"1-1-0",可以通过level判断当前的层级，从而进行不同的操作
                    // // 	        this.textNodeclick(args,level);
                }
            },
            //编辑节点
            editCurrentNode() {
                //隐藏右键菜单
                $('#rightMenu').css({
                    'display': 'none',
                    'left': '-9999px',
                    'top': '-9999px'
                });
                //显示编辑窗口
                this.editDialogVisible = true;
            },
            //add子节点
            addNode(node, childnode){
                if (childnode.indice.father_id == node.indice.indice_id) {
                    //console.log('找到了');
                    var len = node.children.length;
                    node.children[len] = childnode;
                    node.collapsed = false;
                    return true;
                }
                for (let i = 0; i < node.children.length; i++) {
                    var flag = this.addNode(node.children[i], childnode);
                    if (flag == true) {
                        return true;
                    }
                }
            },
            collapseTreeNode(node){
                node.collapsed = true;
                //console.log('name:', node.name);
                //console.log('collapse:', node.collapsed);
                for (let i = 0; i < node.children.length; i++) {
                    this.collapseTreeNode(node.children[i]);
                }
            },
            updateTreeNode(node){
                if (this.currentNode.indice.indice_id == node.indice.indice_id) {
                    node.indice.indice_name = this.currentNode.indice.indice_name;
                    node.name = this.currentNode.indice.indice_name;
                    node.indice.indice_weight = this.currentNode.indice.indice_weight;
                    node.indice.operator_id = this.currentNode.indice.operator_id;
                    //console.log(node.indice.indice_name);
                    return true;
                }
                for (let i = 0; i < node.children.length; i++) {
                    var flag = this.updateTreeNode(node.children[i]);
                    if (flag == true) {
                        return true;
                    }
                }
            },
            //增加子节点
            addChildNode() {
                //隐藏右键菜单
                $('#rightMenu').css({
                    'display': 'none',
                    'left': '-9999px',
                    'top': '-9999px'
                });
                //创建节点信息
                var _this = this;
                let childnode = {
                    name: 'new node',
                    indice: {
                        indice_id: '',
                        indice_name: 'new node',
                        indice_weight: 0,
                        indice_value: '',
                        father_id: this.currentNode.indice.indice_id,
                        scheme_id: this.scheme_id
                    },
                    children: []
                };
                axios({
                    method: "post",
                    url: _this.urlHeader + 'addTreeNode.do',
                    data: childnode.indice
                }).then(function (resp) {
                    childnode.indice.indice_id = resp.data;
                    _this.addNode(_this.tree_struct, childnode);
                    _this.drawTree();
                    _this.$message({
                            message: '添加节点成功',
                            type: 'success'
                    });
                });

            },
            //删除当前节点
            deleteCurrentNode() {
                 //隐藏右键菜单
                 $('#rightMenu').css({
                    'display': 'none',
                    'left': '-9999px',
                    'top': '-9999px'
                });
                var _this=this;
                if(this.currentNode.indice.father_id==-1){
                    //当前是根节点
                    this.$confirm('该节点是根节点,此操作将永久删除该体系, 是否继续?', '提示', {
                        confirmButtonText: '确定',
                        cancelButtonText: '取消',
                        type: 'warning',
                        cancelButtonClass: 'el-button--default el-button--small el-button--cancel'
                    }).then(() => {
                        //发送请求，删除体系及相应指标
                        axios({
                            method:'get',
                            url:_this.urlHeader+'deleteSystemTree.do?scheme_id='+_this.scheme_id
                        }).then(function(resp){
                            _this.$message({
                                type: 'success',
                                message: '删除成功!'
                            });
                            window.location.href=_this.urlHeader+"indiceManagePage.jsp";
                            // window.close();
                        }); 
                    }).catch(() => {
                        this.$message({
                            type: 'info',
                            message: '已取消删除'
                        });       
                    });
                }else{
                    //删除当前节点及所有子节点
                    this.$confirm('此操作将永久删除该节点及其子节点, 是否继续?', '提示', {
                        confirmButtonText: '确定',
                        cancelButtonText: '取消',
                        type: 'warning',
                        cancelButtonClass: 'el-button--default el-button--small el-button--cancel'
                    }).then(() => {
                        //发送请求，删除节点及子节点
                        axios({
                            method:'get',
                            url:_this.urlHeader+'deleteNode.do?indice_id='+_this.currentNode.indice.indice_id,
                        }).then(function(resp){
                            _this.deleteNode(_this.tree_struct,_this.currentNode);
                            _this.drawTree();
                            _this.$message({
                                type: 'success',
                                message: '删除成功!'
                            });
                        });
                    }).catch(() => {
                        this.$message({
                            type: 'info',
                            message: '已取消删除'
                        });      
                       
                    });

                }
            },
            //删除节点
            deleteNode(node,target){
                //if(typeof(node.children)=='undefined')return false;

                for(let i=0;i<node.children.length;i++){
                    if(node.children[i].indice.indice_id==target.indice.indice_id){
                        node.children.splice(i,1);
                        return true;
                    }

                    // if(node.children[i].indice.indice_id==target.indice.father_id){
                    //     return this.deleteNode(node.children[i],target);
                    // }
                }
                for(let i=0;i<node.children.length;i++){
                    // var flag=this.deleteNode(node.children[i],target);
                    // if(flag==true) return true;
                    if(this.deleteNode(node.children[i],target)){
                        return true;
                    }
                }
                return false;
            },
            //编辑确定
            submitNode() {
                var _this = this;
                this.editDialogVisible = false;
                axios({
                    method: 'post',
                    url: _this.urlHeader + 'updateSystemTree.do',
                    data: _this.currentNode.indice,
                }).then(function (resp) {
                    if (resp.data === "success") {
                        _this.$message({
                            message: '修改成功',
                            type: 'success'
                        });
                        _this.updateTreeNode(_this.tree_struct);
                        _this.drawTree();
                    } else {
                        this.$message.error('修改失败');
                    }
                })
            },
            //取消编辑
            cancelEditNode() {
                this.editDialogVisible = false;
            },
            //权重赋值
            formatTooltip(val) {
                return val / 100;
            },
            //获取所有算子
            loadAllOperator() {
                var _this = this;
                var id = ${ sessionScope.currentUser.user_id };
                axios({
                    method: 'post',
                    url: 'http://localhost:2008/SEClassDesign/RequestFromIndiceManagePage.do?request=getUserOperators',
                    data: "user_id=" + id
                }).then(function (resp) {
                    _this.ops = resp.data
                })
            },
            //点击导出体系树JSON
            clickExportSchemeJSON(){
                //console.log('获取到了体系树:\n' + resp.data);
                const fileName = this.scheme_name+".json";
                // 创建Blob对象
                var data = JSON.stringify(this.tree_struct);
                console.log(data);
                const blob = new Blob([data], { type: "text/plain" });

                // 创建URL对象
                const url = URL.createObjectURL(blob);

                // 创建链接元素
                const downloadLink = document.createElement("a");
                downloadLink.href = url;
                downloadLink.download = fileName;

                // 模拟单击下载链接
                document.body.appendChild(downloadLink);
                downloadLink.click();
                document.body.removeChild(downloadLink);
            },

            clickExportSchemeImg(){
                var data = this.tree_struct;
                var _this = this;
                var chartDom = document.getElementById('main');
                var myChart = echarts.init(chartDom, 'dark');
                var option;
                myChart.showLoading();//echarts自带的Loading遮罩方法
                myChart.hideLoading();
                // data.collapsed = false;
                // data.children.forEach(function (datum, index) {
                //     datum.collapsed = false;
                // });
                option = {
                    tooltip: {
                        show: true,
                        trigger: 'item',
                        triggerOn: 'mousemove',
                        position: "bottom",
                        textStyle: {
                            color: "#228EFB",
                            fontSize: 17
                        },
                        extraCssText: 'width:300px;white-space:pre-wrap;',
                        formatter: function (params, ticket, callback) {
                            var tsxx = params.data.describes == "" || params.data.describes == null ? params.data.name : params.data.describes;
                            return tsxx;
                        }
                    },
                    series: [
                        {
                            type: 'tree',
                            data: [data],
                            top: 'middle',
                            left: 'center',
                            // bottom: '1%',
                            // right: '15%',
                            symbolSize: 15,
                            itemStyle: {
                                color: '#228EFB',
                            },
                            lineStyle: {
                                color: '#DDD',
                            },
                            label: {
                                color: "#FFF",
                                position: 'left',
                                verticalAlign: 'middle',
                                align: 'right',
                                fontSize: 18
                            },
                            leaves: {
                                label: {
                                    position: 'right',
                                    verticalAlign: 'middle',
                                    align: 'left'
                                }
                            },
                            emphasis: {
                                focus: 'descendant'
                            },
                            edgeForkPosition: "72%",
                            roam: true,//鼠标缩放，拖拽整颗树
                            expandAndCollapse: true,
                            animationDuration: 550,
                            animationDurationUpdate: 750
                        }
                    ]
                };
                myChart.setOption(option);
                var img = new Image();
                img.src = myChart.getDataURL({
                    type: "png",
                    pixelRatio: 1, //放大2倍
                    backgroundColor: "#fff",
                });
                img.onload = function () {
                    var canvas = document.createElement("canvas");
                    canvas.width = img.width;
                    canvas.height = img.height;
                    var ctx = canvas.getContext("2d");
                    ctx.drawImage(img, 0, 0);
                    var dataURL = canvas.toDataURL("image/png");
                
                    var a = document.createElement("a");
                    a.download = _this.scheme_name+".png";
                    
                    console.log(_this.scheme_name);
                    // 将生成的URL设置为a.href属性
                    a.href = dataURL;
                    // 触发a的单击事件
                    a.click();
                    a.remove();

                };
            },
            backToIndiceManagePage(){
                window.location.href="http://localhost:2008/SEClassDesign/indiceManagePage.jsp";
            }
        },
        mounted() {
            this.scheme_name = '${ param.scheme_name }';
            this.isInstance = ${ param.isInstance };
            this.loadTreeStruct();
            this.loadAllOperator();
        },
    });
</script>

</html>


    