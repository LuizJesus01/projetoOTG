with affiliates as (
    select * from {{ ref('stg_affiliates') }}
),

fraud_players as (
    select player_id, is_fraudulent_player from {{ ref('fct_fraud_alerts') }}
)

select
    a.affiliate_id,
    a.country_code,
    sum(a.total_clicks) as total_clicks,
    sum(a.total_registrations) as total_registrations,
    sum(a.first_time_deposit) as total_ftd,
    sum(a.cpa_amount) as total_cpa_payout,
    
    -- Métrica Avançada para a entrevista: Quantos jogadores trazidos por esse afiliado acionaram alertas de fraude
    sum(coalesce(f.is_fraudulent_player, 0)) as total_fraudulent_players_brought,
    
    -- Taxa de Conversão (Cliques para Registros)
    safe_divide(sum(a.total_registrations), sum(a.total_clicks)) as click_to_reg_conversion_rate

from affiliates a
left join fraud_players f 
    on a.player_id = f.player_id
group by 1, 2
