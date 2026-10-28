<template>
 <div class="app-container">
  <el-alert title="业务数据与权限基础：当前提供查询及产值草稿维护，审批与执行流程在后续阶段实现。" type="info" :closable="false" class="mb8" />
  <el-form inline @submit.prevent="load">
   <el-form-item label="企业编号"><el-input-number v-model="companyId" :min="1" :controls="false" placeholder="默认当前企业" /></el-form-item>
   <el-button type="primary" @click="load">查询</el-button>
   <el-button v-if="module === 'daily_output'" v-hasPermi="['biz:daily_output:add']" @click="open()">新增填报</el-button>
  </el-form>
  <el-table v-loading="loading" :data="rows" border>
   <el-table-column v-for="column in columns" :key="column" :prop="column" :label="labels[column] || column" min-width="140" show-overflow-tooltip />
   <el-table-column v-if="module === 'daily_output'" label="操作" fixed="right" width="100"><template #default="{row}"><el-button v-hasPermi="['biz:daily_output:edit']" link type="primary" :disabled="!['DRAFT','RETURNED'].includes(row.status)" @click="open(row)">编辑</el-button></template></el-table-column>
  </el-table>
  <el-empty v-if="!loading && !rows.length" description="暂无可访问记录" />
  <pagination v-show="total > 0" v-model:page="pageNum" v-model:limit="pageSize" :total="total" @pagination="load" />
  <el-dialog v-model="visible" title="业务产值填报" width="500px">
   <el-form label-width="100px">
    <el-form-item label="企业编号"><el-input-number v-model="form.companyId" :min="1" :disabled="!!form.id" /><span>企业用户可留空</span></el-form-item>
    <el-form-item label="业务日期"><el-date-picker v-model="form.outputDate" value-format="YYYY-MM-DD" /></el-form-item>
    <el-form-item label="产值"><el-input-number v-model="form.outputValue" :min="0" :precision="2" /></el-form-item>
    <el-form-item label="单位"><el-input v-model="form.unit" maxlength="20" /></el-form-item>
    <el-form-item label="备注"><el-input v-model="form.remark" maxlength="500" type="textarea" /></el-form-item>
   </el-form>
   <template #footer><el-button @click="visible=false">取消</el-button><el-button type="primary" :loading="saving" @click="save">保存</el-button></template>
  </el-dialog>
 </div>
</template>
<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { listRecords, addOutput, editOutput } from '@/api/business/records'
const route=useRoute(), module=computed(()=>String(route.query.module || route.path.split('/').pop()))
const labels={"id": "编号", "company_id": "企业编号", "status": "状态", "version": "版本", "create_by": "创建人", "create_time": "创建时间", "update_by": "更新人", "update_time": "更新时间", "remark": "备注", "company_name": "申请企业名称", "credit_code": "信用代码", "contact_name": "联系人", "contact_phone": "联系电话", "address": "地址", "applicant_id": "申请人", "qualification_ref": "资质附件引用", "round_no": "审批轮次", "user_id": "员工账号", "job_title": "岗位", "employee_no": "企业内工号", "real_name": "姓名", "entry_date": "入职日期", "leave_date": "离职日期", "device_code": "设备编号", "valid_from": "有效期开始", "valid_to": "有效期结束", "sync_status": "同步状态PENDING/SUCCESS/FAILED", "last_error": "最后同步错误", "output_date": "业务日期", "output_value": "每日产值，不小于0", "unit": "工作量单位", "project_code": "企业内项目编号", "project_name": "项目名称", "owner_user_id": "负责人账号", "start_date": "开始日期", "end_date": "结束日期", "task_code": "全局任务编号", "title": "任务标题", "publisher_type": "PLATFORM/COMPANY", "description": "任务说明", "project_id": "所属项目", "target_quantity": "目标工作量", "signup_deadline": "报名截止时间", "task_id": "任务", "contact_user_id": "报名联系人", "promised_quantity": "承诺数量", "signup_id": "审核通过的报名记录", "assigned_quantity": "分配工作量", "due_date": "截止日期", "assignment_id": "分配记录", "work_date": "工作日期", "quantity": "上报工作量", "evidence_ref": "工作凭证引用", "business_type": "业务类型", "business_id": "业务ID，按business_type逻辑关联", "reviewer_id": "审核人", "from_status": "原状态", "to_status": "新状态", "opinion": "审核意见", "reviewed_at": "审核时间"}
const rows=ref([]), total=ref(0), loading=ref(false), companyId=ref(), pageNum=ref(1),pageSize=ref(20),visible=ref(false),saving=ref(false),form=ref({})
const columns=computed(()=>rows.value.length?Object.keys(rows.value[0]).filter(k=>!['active_user','qualification_ref','evidence_ref'].includes(k)):['id','company_id','status'])
let requestId=0
async function load(){const id=++requestId;loading.value=true;try{const response=await listRecords(module.value,{companyId:companyId.value,pageNum:pageNum.value,pageSize:pageSize.value});if(id===requestId){rows.value=response.data.rows;total.value=response.data.total}}catch{if(id===requestId){rows.value=[];total.value=0}}finally{if(id===requestId)loading.value=false}}
function open(row){form.value=row?{id:row.id,companyId:row.company_id,outputDate:String(row.output_date).slice(0,10),outputValue:Number(row.output_value),unit:row.unit,remark:row.remark,version:row.version}:{companyId:companyId.value,outputValue:0,unit:'元',remark:''};visible.value=true}
async function save(){if(!form.value.outputDate || !form.value.unit){ElMessage.warning('请填写日期和单位');return}saving.value=true;try{if(form.value.id)await editOutput(form.value.id,form.value);else await addOutput(form.value);visible.value=false;ElMessage.success('保存成功');await load()}finally{saving.value=false}}
watch(module,()=>{rows.value=[];total.value=0;pageNum.value=1;companyId.value=undefined;visible.value=false;load()},{immediate:true})
</script>
