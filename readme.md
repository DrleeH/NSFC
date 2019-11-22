# Description

This project provide some functions to download NSFC(National Natural Science Foundation of China) information from <http://fund.sciencenet.cn/>

The information including `project id`, `filde code`, `winning year`, `project title`, `project manager`, `institution`, `project type`, `funding number`. som of project also has `keywords` and `abstract`.

## NSFC.R

This function can download all winning project informaition for a specified time in a certain filed. 

The function has four parameters:

- items: the filed code like `H2001`. this parameter can include multiple filed. 
- StartYear: start time in this search
- EndYear: end time in this search
- Abstract: Logical. Whether to download the abstract. when we shoose `TRUE`. the download speed will be very slow.
- ProjectId: if this parameter is null(default), the function will download all of the project. the project can be "面上项目", "青年科学基金项目",  "地区科学基金项目", "国际(地区)合作与交流项目", "专项基金项目", "重点项目", "联合基金项目",  "重大研究计划", "应急管理项目", "国家情况杰出基因项目",  "重大项目", "海外及港澳学者合作研究基金", "国家基础科学人才培养基金",  "创新研究群体项目", "海外或港、澳青年学者合作研究基金", "国家重大科研仪器研制项目", "国家重大科研仪器设备研制专项","创新研究群体科学基金", "科学中心项目", "其他"

**BTW**: if the number of one  project in one year is more than 200, only download 200 result.

