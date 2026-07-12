with players as (
    select * from {{ ref('stg_players') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- Agrupando transações por jogador para gerar os totalizadores
player_transactions_aggregated as (
    select
        player_id,
        count(case when transaction_type = 'deposit' then 1 end) as total_deposits_count,
        coalesce(sum(case when transaction_type = 'deposit' then transaction_amount end), 0) as total_deposited_amount,
        
        count(case when transaction_type = 'withdraw' then 1 end) as total_withdrawals_count,
        coalesce(sum(case when transaction_type = 'withdraw' then transaction_amount end), 0) as total_withdrawn_amount,
        
        count(case when transaction_type = 'bet' then 1 end) as total_bets_count,
        coalesce(sum(case when transaction_type = 'bet' then transaction_amount end), 0) as total_bet_amount
    from transactions
    group by 1
)

-- Cruzando dados cadastrais com o agregado financeiro
select
    p.player_id,
    p.player_email,
    p.player_city,
    p.account_created_at,
    t.total_deposits_count,
    t.total_deposited_amount,
    t.total_withdrawals_count,
    t.total_withdrawn_amount,
    t.total_bets_count,
    t.total_bet_amount
from players p
left join player_transactions_aggregated t 
    on p.player_id = t.player_id
