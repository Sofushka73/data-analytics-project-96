--dashboard utm_all

select
    utm_campaign,
    utm_source,
    utm_medium,
    round(
        sum(total_cost)
        / sum(visitors_count)
    ) as cpu,
    case
        when sum(leads_count) = 0 then 0
        else round(sum(total_cost) / sum(leads_count))
    end as cpi,
    case
        when sum(purchases_count) = 0 then 0
        else round(sum(total_cost) / sum(purchases_count))
    end as cppu,
    round(((
        sum(revenue) - sum(total_cost)
    )
    / sum(total_cost)
    ) * 100
    ) as roi
from (
    select
        va.utm_campaign,
        va.utm_source,
        va.utm_medium,
        count(s.visitor_id) over (partition by s.visit_date) as visitors_count,
        sum(va.daily_spent) as total_cost,
        count(l.lead_id) over (partition by s.visit_date) as leads_count,
        count(l.lead_id) filter (where l.status_id = 142) as purchases_count,
        sum(l.amount) filter (where l.status_id = 142) as revenue
    from sessions as s
    left join vk_ads as va
        on
            s.medium = va.utm_medium
            and s.source = va.utm_source
            and s.campaign = va.utm_campaign
    left join leads as l
        on
            s.visitor_id = l.visitor_id
    group by
        s.visitor_id, l.lead_id, s.visit_date,
        va.utm_campaign, va.utm_source, va.utm_medium
) as tab
where utm_campaign is not null
group by utm_campaign, utm_source, utm_medium
union
select
    utm_campaign,
    utm_source,
    utm_medium,
    round(
        sum(total_cost)
        / sum(visitors_count)
    ) as cpu,
    case
        when sum(leads_count) = 0 then 0
        else round(sum(total_cost) / sum(leads_count))
    end as cpi,
    case
        when sum(purchases_count) = 0 then 0
        else round(sum(total_cost) / sum(purchases_count))
    end as cppu,
    round(((sum(revenue) - sum(total_cost)) / sum(total_cost)) * 100) as roi
from (
    select
        ya.utm_campaign,
        ya.utm_source,
        ya.utm_medium,
        count(s.visitor_id) over (partition by s.visit_date)
        as visitors_count,
        sum(ya.daily_spent) as total_cost,
        count(l.lead_id) over (partition by s.visit_date) as leads_count,
        count(l.lead_id) filter (where l.status_id = 142)
        as purchases_count,
        sum(l.amount) filter (where l.status_id = 142) as revenue
    from sessions as s
    left join ya_ads as ya
        on
            s.medium = ya.utm_medium
            and s.source = ya.utm_source
            and s.campaign = ya.utm_campaign
    left join leads as l
        on
            s.visitor_id = l.visitor_id
    group by
        s.visitor_id, l.lead_id, s.visit_date, ya.utm_campaign, ya.utm_source,
        ya.utm_medium
) as tab
where utm_campaign is not null
group by
    utm_campaign, utm_source, utm_medium;

--dashboard day/week/month count

select
    va.utm_source,
    va.utm_medium,
    va.utm_campaign,
    date_trunc('month', s.visit_date) as visit_date,
    count(distinct s.visitor_id) as visitors_count
from sessions as s
left join vk_ads as va
    on
        s.source = va.utm_source
        and s.medium = va.utm_medium
        and s.campaign = va.utm_campaign
where va.utm_source is not null
group by
    date_trunc('month', visit_date), va.utm_source, va.utm_medium,
    va.utm_campaign
union
select
    ya.utm_source,
    ya.utm_medium,
    ya.utm_campaign,
    date_trunc('month', s.visit_date) as visit_date,
    count(distinct s.visitor_id) as visitors_count
from sessions as s
left join ya_ads as ya
    on
        s.source = ya.utm_source
        and s.medium = ya.utm_medium
        and s.campaign = ya.utm_campaign
where ya.utm_source is not null
group by
    date_trunc('month', s.visit_date), ya.utm_source, ya.utm_medium,
    ya.utm_campaign;

--dashboard conversion

select
    tab.utm_source,
    tab.utm_medium,
    tab.utm_campaign,
    tab.revenue
    - tab.total_cost as profit
from (
    select
        va.utm_source,
        va.utm_medium,
        va.utm_campaign,
        sum(va.daily_spent) as total_cost,
        sum(l.amount) as revenue
    from sessions as s
    left join vk_ads as va
        on
            s.source = va.utm_source
            and s.medium = va.utm_medium
            and s.campaign = va.utm_campaign
    left join leads as l
        on
            s.visitor_id = l.visitor_id
    where va.utm_source is not null
    group by
        va.utm_source, va.utm_medium, va.utm_campaign
) as tab
union
select
    tab.utm_source,
    tab.utm_medium,
    tab.utm_campaign,
    tab.revenue
    - tab.total_cost as profit
from (
    select
        ya.utm_source,
        ya.utm_medium,
        ya.utm_campaign,
        sum(ya.daily_spent) as total_cost,
        sum(l.amount) as revenue
    from sessions as s
    left join ya_ads as ya
        on
            s.source = ya.utm_source
            and s.medium = ya.utm_medium
            and s.campaign = ya.utm_campaign
    left join leads as l
        on
            s.visitor_id = l.visitor_id
    where ya.utm_source is not null
    group by
        ya.utm_source, ya.utm_medium, ya.utm_campaign
) as tab;

--dashboard day/week/month total cost

select
    utm_source,
    utm_medium,
    utm_campaign,
    visit_date,
    total_cost
from (
    select
        va.utm_source,
        va.utm_medium,
        va.utm_campaign,
        to_char((date_trunc('month', s.visit_date)), 'yyyy-mm-dd')
        as visit_date,
        sum(va.daily_spent) as total_cost
    from sessions as s
    left join vk_ads as va
        on
            s.source = va.utm_source
            and s.medium = va.utm_medium
            and s.campaign = va.utm_campaign
    where va.utm_source is not null
    group by
        va.utm_source, va.utm_medium, va.utm_campaign
) as tab
union
select
    utm_source,
    utm_medium,
    utm_campaign,
    visit_date,
    total_cost
from (
    select
        ya.utm_source,
        ya.utm_medium,
        ya.utm_campaign,
        to_char((date_trunc('month', s.visit_date)), 'yyyy-mm-dd')
        as visit_date,
        sum(ya.daily_spent) as total_cost
    from sessions as s
    left join ya_ads as ya
        on
            s.source = ya.utm_source
            and s.medium = ya.utm_medium
            and s.campaign = ya.utm_campaign
    where ya.utm_source is not null
    group by
        ya.utm_source, ya.utm_medium, ya.utm_campaign
) as tab;

--Вычисления для выявлелия кореляции между запуском рекламы и ростом органики

select count(distinct s.visitor_id)
from sessions as s
left join vk_ads as va
    on
        s.source = va.utm_source
        and s.medium = va.utm_medium
        and s.campaign = va.utm_campaign
left join leads as l
    on
        s.visitor_id = l.visitor_id
where va.utm_source is null and l.created_at <= '2023-06-30 18:28:25.000';
-- created_at <= '2023-06-01 01:58:59.000'

select max(created_at)

--min(created_at)

from (
    select distinct
        s.visitor_id,
        l.lead_id,
        s.visit_date,
        l.created_at,
        l.status_id,
        l.created_at - s.visit_date as times
    from sessions as s
    left join leads as l
        on
            s.visitor_id = l.visitor_id
    where l.status_id = '142'
    order by s.visit_date asc, l.created_at asc
) as tab;

--Вычисление времени когда можно начинать анализ дашборда

select avg(time)
from (
    select distinct
        s.visitor_id,
        l.lead_id,
        s.visit_date,
        l.created_at,
        l.status_id,
        l.created_at - s.visit_date as times
    from sessions as s
    left join leads as l
        on
            s.visitor_id = l.visitor_id
            and s.visit_date < l.created_at
    where l.status_id = '142'
    order by s.visit_date asc, l.created_at asc
) as tab;

--вычисления где вычислялся промежуток покрытия 90%

--select min/max(time)

select count(visitor_id)
from (
    select distinct
        s.visitor_id,
        l.lead_id,
        s.visit_date,
        l.created_at,
        l.status_id,
        l.created_at - s.visit_date as times
    from sessions as s
    left join leads as l
        on
            s.visitor_id = l.visitor_id
            and s.visit_date < l.created_at
    where l.status_id = '142'
    order by s.visit_date asc, l.created_at asc
) as tab
where times between '00:17:16.678171' and '23 days 09:25:25'
