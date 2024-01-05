select 
distinct s.visitor_id, s.visit_date,
utm_source, utm_medium, utm_campaign,
lead_id, created_at,
sum(l.amount) as amount,
closing_reason, status_id 
from sessions s 
left join leads l 
on s.visitor_id = l.visitor_id 
left join ya_ads ya 
on s.medium = ya.utm_medium and 
s.source = ya.utm_source and 
s.campaign = ya.utm_campaign 
group by 1,2,3,4,5,6,7,9,10


union 

select 
distinct s.visitor_id, s.visit_date,
utm_source, utm_medium, utm_campaign,
lead_id, created_at,
sum(l.amount) as amount,
closing_reason, status_id 
from sessions s 
left join leads l 
on s.visitor_id = l.visitor_id 
left join vk_ads va 
on s.medium = va.utm_medium and 
s.source = va.utm_source and 
s.campaign = va.utm_campaign 
group by 1,2,3,4,5,6,7,9,10
order by amount desc nulls last, s.visit_date asc, utm_source asc, utm_medium asc, utm_campaign asc, created_at desc
limit 10