<!DOCTYPE html>
<html lang="zh-CN">
<head>

<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">

<!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
<title></title>

<!-- Bootstrap -->
<!-- 最新版本的 Bootstrap 核心 CSS 文件 -->
<link rel="stylesheet" href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<style>
body {
padding: 60px;
}

.tips {
margin-bottom: 80px;
text-align: center;
font-size: 3em;
}

.tips .node {
height: 40px;
line-height: 40px;
}

.tips .node-icon {
display: block;
float: left;
}

.tips .node-name {
display: block;
float: left;
margin: 0;
padding: 0;
height: 40px;
line-height: 40px;
font-size: 0.8em;
padding-left: 6px;
}

.tips .done {
color: #54ae3b;
font-size: 1.6em;
display: inline-block;
height: 40px;
line-height: 40px;

}

.tips .current {
color: #e8a02a;
font-size: 1.6em;
display: inline-block;
height: 40px;
line-height: 40px;
}

.tips .pending {
color: rgb(100,100,100);
font-size: 1.6em;
display: inline-block;
height: 40px;
line-height: 40px;
}

.timeline {
width: 97%;
margin: 0 auto;
}

.timeline-row {
position: relative;
}

.timeline-body {
height: 100%;
clear: both;
margin-left: 10px;
padding-left: 40px;
border-left: 1px solid rgb(203,203,203);
padding-bottom: 80px;
font-size: 2.6em;
}

.timeline-body-no-border {
border-left: 0;
}

.timeline-body h2 {
margin: 0;
padding: 0;
padding-top: 5px;
font-size: 1em;
}

.timeline-body .note-item {
float: right;
display: inline-block;
}

.timeline-body .note-item .custom-btn {
display: inline-block;
width: 100%;
font-size: 1em;
color: red;
}

.timeline-body .gray {
color: #cbcbcb;
}

.timeline-body:before {
content: '';
width: 48px;
height: 48px;
position: absolute;
left: -14px;
top: 5px;
border-radius: 100%;
z-index: 101;
background-color: rgb(100,100,100);
background-image: none;
background-size: contain;
background-position: center center;
background-repeat: no-repeat;
}

.done:before {
left: -20px;
width: 60px;
height: 60px;
background-color: white;
background-image: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB0PSIxNDk3MjUwOTAwMzY1IiBjbGFzcz0iaWNvbiIgc3R5bGU9IiIgdmlld0JveD0iMCAwIDEwMjQgMTAyNCIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHAtaWQ9IjQ0OTIiIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCI+PGRlZnM+PHN0eWxlIHR5cGU9InRleHQvY3NzIj48L3N0eWxlPjwvZGVmcz48cGF0aCBkPSJNNTEyIDk2MEMyNjQuOTYgOTYwIDY0IDc1OS4wNCA2NCA1MTJTMjY0Ljk2IDY0IDUxMiA2NHM0NDggMjAwLjk2IDQ0OCA0NDhTNzU5LjA0IDk2MCA1MTIgOTYwek01MTIgMTI4LjI4OEMzMDAuNDE2IDEyOC4yODggMTI4LjI4OCAzMDAuNDE2IDEyOC4yODggNTEyYzAgMjExLjU1MiAxNzIuMTI4IDM4My43MTIgMzgzLjcxMiAzODMuNzEyIDIxMS41NTIgMCAzODMuNzEyLTE3Mi4xNiAzODMuNzEyLTM4My43MTJDODk1LjcxMiAzMDAuNDE2IDcyMy41NTIgMTI4LjI4OCA1MTIgMTI4LjI4OHoiIHAtaWQ9IjQ0OTMiIGZpbGw9IiM1NGFlM2IiPjwvcGF0aD48cGF0aCBkPSJNNzI2Ljk3NiAzOTMuMTg0Yy0xMi41NDQtMTIuNDQ4LTMyLjgzMi0xMi4zMi00NS4yNDggMC4yNTZsLTIzMy4yOCAyMzUuODQtMTAzLjI2NC0xMDYuMTEyYy0xMi4zNTItMTIuNzA0LTMyLjYwOC0xMi45MjgtNDUuMjQ4LTAuNjQtMTIuNjcyIDEyLjMyLTEyLjk2IDMyLjYwOC0wLjY0IDQ1LjI0OGwxMjYuMDE2IDEyOS41MDRjMC4wNjQgMC4wOTYgMC4xOTIgMC4wOTYgMC4yNTYgMC4xOTIgMC4wNjQgMC4wNjQgMC4wOTYgMC4xOTIgMC4xNiAwLjI1NiAyLjAxNiAxLjk4NCA0LjUxMiAzLjIgNi44OCA0LjU0NCAxLjI0OCAwLjY3MiAyLjI0IDEuNzkyIDMuNTIgMi4zMDQgMy44NzIgMS42IDggMi40IDEyLjA5NiAyLjQgNC4wNjQgMCA4LjEyOC0wLjggMTEuOTY4LTIuMzM2IDEuMjQ4LTAuNTEyIDIuMjA4LTEuNTM2IDMuMzkyLTIuMTc2IDIuNC0xLjM0NCA0Ljg5Ni0yLjUyOCA2Ljk0NC00LjU0NCAwLjA2NC0wLjA2NCAwLjA5Ni0wLjE5MiAwLjE5Mi0wLjI1NiAwLjA2NC0wLjA5NiAwLjE2LTAuMTI4IDAuMjU2LTAuMTkybDI1Ni4yMjQtMjU5LjAwOEM3MzkuNjQ4IDQyNS44NTYgNzM5LjUyIDQwNS42IDcyNi45NzYgMzkzLjE4NHoiIHAtaWQ9IjQ0OTQiIGZpbGw9IiM1NGFlM2IiPjwvcGF0aD48L3N2Zz4=');

}

.current:before {
background-color:#e8a02a;
}

.mask {
z-index: 100;
width: 8px;
height: 14px;
position: absolute;
background-color: white;
}

.top-pos {
top: 0px;
left: 9px;
height: 16px;
}

.bottom-pos {
bottom: 0;
left: 9px;
height: 148px;
}
</style>

</head>
<body>

<div class="timeline">
{{content}}
</div>

</body>
</html>
