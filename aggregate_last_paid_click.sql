select visit_date,utm_source, utm_medium, utm_campaign,
visitors_count, total_cost, leads_count, purchases_count, revenue
from (select 
visit_date ,
va.utm_source, va.utm_medium, va.utm_campaign,
count(s.visitor_id) over (partition by visit_date) as visitors_count,
sum(va.daily_spent) as total_cost,
count(l.lead_id) over (partition by visit_date) as leads_count,
count(l.lead_id) filter(where l.closing_reason = 'Успешно реализовано' or l.status_id = 142) as purchases_count,
sum(amount) filter(where l.closing_reason = 'Успешно реализовано' or l.status_id = 142) as revenue
from sessions s 
left join vk_ads va 
on s.medium = va.utm_medium and 
s.source = va.utm_source and 
s.campaign = va.utm_campaign 
left join leads l 
on s.visitor_id = l.visitor_id 
group by 1,2,3,4, s.visitor_id, l.lead_id
order by visit_date desc) as tab

union

select visit_date,utm_source, utm_medium, utm_campaign,
visitors_count, total_cost, leads_count, purchases_count, revenue
from (select 
visit_date ,
ya.utm_source, ya.utm_medium, ya.utm_campaign,
count(s.visitor_id) over (partition by visit_date) as visitors_count,
sum(ya.daily_spent) as total_cost,
count(l.lead_id) over (partition by visit_date)as leads_count,
count(l.lead_id) filter(where l.closing_reason = 'Успешно реализовано' or l.status_id = 142) as purchases_count,
sum(amount) filter(where l.closing_reason = 'Успешно реализовано' or l.status_id = 142) as revenue
from sessions as s 
left join ya_ads as ya  
on s.medium = ya.utm_medium and 
s.source = ya.utm_source and 
s.campaign = ya.utm_campaign 
left join leads as l 
on s.visitor_id = l.visitor_id 
group by 1,2,3,4, s.visitor_id, l.lead_id 
order by visit_date desc) as tab
order by 9 desc nulls last, visit_date asc, visitors_count desc, utm_source asc, utm_medium asc, utm_campaign asc
limit 15
