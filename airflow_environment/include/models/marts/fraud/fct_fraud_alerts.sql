with financial_behavior as (
    select * from {{ ref('int_player_financial_behavior') }}
),

sessions_behavior as (
    select * from {{ ref('int_player_sessions_behavior') }}
),

fraud_indicators as (
    select
        f.player_id,
        f.player_email,
        f.player_city,
        f.account_created_at,
        
        -- Métricas financeiras e de navegação consolidadas
        f.total_deposited_amount,
        f.total_withdrawn_amount,
        f.total_bet_amount,
        s.distinct_ips_count,
        s.distinct_devices_count,
        
        -- Regra de Fraude 1: Saque sem apostas (Lavagem de dinheiro / Abuso de bônus)
        -- Usuário deposita, não aposta quase nada, e saca o valor quase integral
        case 
            when f.total_deposited_amount > 0 and f.total_bet_amount < (f.total_deposited_amount * 0.20) and f.total_withdrawn_amount > 0
            then 1 
            else 0 
        end as flag_suspicious_withdrawal,

        -- Regra de Fraude 2: Multi-Accounting (Abuso de Contas / IPs rotativos)
        -- Um único jogador acessando a conta por mais de 2 IPs ou dispositivos diferentes
        case 
            when s.distinct_ips_count > 2 or s.distinct_devices_count > 2
            then 1 
            else 0 
        end as flag_multi_accounting

    from financial_behavior f
    left join sessions_behavior s 
        on f.player_id = s.player_id
)

select 
    *,
    -- Flag consolidada se o jogador acionou qualquer um dos alertas de fraude
    case when flag_suspicious_withdrawal = 1 or flag_multi_accounting = 1 then 1 else 0 end as is_fraudulent_player
from fraud_indicators
