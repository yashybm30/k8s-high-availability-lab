import http from 'k6/http';
import {check} from 'k6';
export const options={stages:[{duration:'30s',target:20},{duration:'3m',target:80},{duration:'30s',target:0}],thresholds:{http_req_failed:['rate<0.01'],http_req_duration:['p(95)<2000']}};
export default function(){const r=http.get(`${__ENV.BASE_URL||'http://localhost:3000'}/v1/work?iterations=500000`);check(r,{'success':r=>r.status===200});}
