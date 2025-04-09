<template>
    <!-- 组件的结构 -->
    <div class="demo">
        <h2>学生名称：{{name}}</h2>
        <h2>学生年龄：{{age}}</h2>
    </div>
</template>


<script>
    //组件交互的相关代码（数据方法等）
    export default {
        name:'Student',
        data(){
            return{
                name:'张三',
                age:18
            }
        },
    }
</script>

<style>
    /* 组件的样式 */
    .demo{
        background-color: aliceblue;
    }
</style>