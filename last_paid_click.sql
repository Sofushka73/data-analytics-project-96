select distinct on (visitor_id )
visitor_id, visit_date ,
utm_source, utm_medium , utm_campaign,
lead_id, created_at,
amount,
closing_reason, status_id
from (select 
s.visitor_id, s.visit_date ,
va.utm_source, va.utm_medium, va.utm_campaign,
l.lead_id, l.created_at,
sum(l.amount) as amount,
closing_reason, status_id
from sessions s 
left join leads l 
on s.visitor_id = l.visitor_id
left join vk_ads va  
on s.medium = va.utm_medium and 
s.source = va.utm_source and 
s.campaign = va.utm_campaign
where utm_medium = 'cpc' or utm_medium = 'cpm' or utm_medium = 'cpa' or utm_medium = 'youtube'
or utm_medium = 'cpp' or utm_medium = 'tg'or utm_medium = 'social'
group by 1,2,3,4,5,6,7,9,10
order by visit_date desc) as tab

union

select distinct on (visitor_id) 
visitor_id, visit_date ,
utm_source, utm_medium , utm_campaign,
lead_id, created_at,
amount,
closing_reason, status_id
from (select 
s.visitor_id, s.visit_date ,
ya.utm_source, ya.utm_medium, ya.utm_campaign,
l.lead_id, l.created_at,
sum(l.amount) as amount,
closing_reason, status_id 
from sessions s 
left join leads l 
on s.visitor_id = l.visitor_id
left join ya_ads as ya  
on s.medium = ya.utm_medium and 
s.source = ya.utm_source and 
s.campaign = ya.utm_campaign
where utm_medium = 'cpc' or utm_medium = 'cpm' or utm_medium = 'cpa' or utm_medium = 'youtube'
or utm_medium = 'cpp' or utm_medium = 'tg'or utm_medium = 'social'
group by 1,2,3,4,5,6,7,9,10
order by visit_date desc) as tab
order by amount desc nulls last, visit_date asc, utm_source asc, utm_medium asc, utm_campaign asc
