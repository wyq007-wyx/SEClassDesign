<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
    <title>Echarts 树形图示例</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport' />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <link href='./bootstrap/css/bootstrap.css' media='all' rel='stylesheet' type='text/css' />
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
    </style>
</head>

<body class='contrast-blue'>
    <div id="app">
        <div style="background-color: rgb(16,12,42); height: 15vh; " >
            <el-button type="primary" style="margin: 10px 10px 10px 10px; float: right; width: 150px;"
                @click="backToresultManagePage" plain>
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
            <el-button style="width: 150px;" @click="editCurrentNode">查看当前节点</el-button>
        </div>

        <!-- 查看节点窗口 -->
        <el-dialog id="editNodeDialog" width="400px" title="查看指标" :visible.sync="editDialogVisible" center>
            <el-form ref="nodeform" :model="currentNode"  label-width="80px"
                style="height: 300px;overflow-y: auto;">
                <el-form-item label="指标id" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_id" disabled></el-input>
                </el-form-item>
                <el-form-item label="指标名" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_name" disabled></el-input>
                </el-form-item>
                <el-form-item label="指标权重" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_weight/100" disabled></el-input>
                </el-form-item>
                <el-form-item label="指标值" style="width:310px">
                    <el-input v-model="currentNode.indice.indice_value" disabled></el-input>
                </el-form-item>
                <el-form-item label="父节点id" style="width:310px">
                    <el-input v-model="currentNode.indice.father_id" disabled></el-input>
                </el-form-item>
                <el-form-item label="算子" style="width:310px">
                    <el-select v-model="currentNode.indice.operator_id" placeholder="选择算子" disabled>
                        <el-option v-for="item in ops" :label="item.operator_description" :value="item.operator_id"
                            :key="item.operator_id">
                        </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="系统id" style="width:310px">
                    <el-input v-model="currentNode.indice.scheme_id" disabled></el-input>
                </el-form-item>
            </el-form>
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
                //所有算子
                ops: [
                    {
                        operator_id: '',
                        operator_description: ''
                    }
                ],
                //编辑窗口是否可见
                editDialogVisible: false,
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
                var str =sessionStorage.getItem('chosentree');
                this.tree_struct = JSON.parse(str);
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
                myChart.on("contextmenu", function (params) {
                    gloab_param = params;
                    $('#rightMenu').css({
                        'display': 'block',
                        'left': params.event.offsetX,//此处根据自己实际情况调整右键操作菜单显示位置
                        'top': params.event.offsetY + 60
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
                }
            },
            //查看节点
            editCurrentNode() {
                //隐藏右键菜单
                $('#rightMenu').css({
                    'display': 'none',
                    'left': '-9999px',
                    'top': '-9999px'
                });
                //显示查看窗口
                this.editDialogVisible = true;
            },
            collapseTreeNode(node){
                node.collapsed = true;
                for (let i = 0; i < node.children.length; i++) {
                    this.collapseTreeNode(node.children[i]);
                }
            },
            //获取所有算子
            loadAllOperator() {
                var _this = this;
                axios({
                    method: 'post',
                    url: _this.urlHeader + 'RequestFromIndiceManagePage.do?request=getAllOperators',
                }).then(function (resp) {
                    _this.ops = resp.data
                })
            },
            //点击导出体系树JSON
            clickExportSchemeJSON(){
                var _this=this;
                axios({
                    method:"get",
                    url:_this.urlHeader+"getSchemeName.do?scheme_id="+_this.tree_struct.indice.scheme_id
                }).then(function(resp){
                    //console.log('获取到了体系树:\n' + resp.data);
                    const fileName = resp.data+".json";
                    // 创建Blob对象
                    var data = JSON.stringify(_this.tree_struct);
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
                });
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
            backToresultManagePage(){
                window.location.href="http://localhost:2008/SEClassDesign/resultManagePage.jsp";
            },
        },
        mounted() {
            this.loadTreeStruct();
            this.loadAllOperator();
        },
    });
</script>

</html>

