<template>
    <!-- 组件的结构 -->
    <div class="demo">
        <h2>学校名称：{{schoolName}}</h2>
        <h2>学校地址：{{schoolAddress}}</h2>
        <button @click="showName">点我提示学校名</button>
    </div>
</template>


<script>
    //组件交互的相关代码（数据方法等）
    const school = Vue.extends({
        data(){
            return{
                schoolName:'希望小学',
                schoolAddress:'希望路'
            }
        },
        methods:{
            showName(){
                alert(this.schoolName)
            }
        }
    })
    export default school
</script>

<style>
    /* 组件的样式 */
    .demo{
        background-color: beige;
    }
</style>