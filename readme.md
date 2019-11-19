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

