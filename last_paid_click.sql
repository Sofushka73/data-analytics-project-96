select tabb.visitor_id, visit_date, source as utm_source,
    medium as utm_medium, campaign as utm_campaign,
    lead_id, created_at, sum(amount) as amount,
    closing_reason, status_id
from
   (select distinct on(visitor_id) visitor_id,
       s.visit_date, s.source, s.medium,
       s.campaign 
   from sessions as s 
   where medium = 'cpc' or medium = 'cpm'
   or medium = 'cpa' or medium = 'youtube'
   or medium = 'cpp' or medium = 'tg'
   or medium = 'social'
   order by visitor_id, visit_date desc
   ) as tabb 
   left join leads as l 
      on tabb.visitor_id = l.visitor_id 
group by tabb.visitor_id, visit_date, utm_source, utm_medium, utm_campaign,
    lead_id, created_at, closing_reason, status_id
order by amount desc nulls last,
   visit_date asc, utm_source asc,
   utm_medium asc, utm_campaign asc
limit 10
