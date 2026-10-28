import request from '@/utils/request'
export const listRecords = (module, params) => request({ url: `/biz/${module}/list`, method: 'get', params })
export const addOutput = data => request({ url: '/biz/daily_output', method: 'post', data })
export const editOutput = (id, data) => request({ url: `/biz/daily_output/${id}`, method: 'put', data })
