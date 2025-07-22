;; Contract: StackTax
;; Description: FIFO Capital Gains & Tax Example
;; ------------------------------------------------------------

;; --------------------------------------------
;; Maps
;; --------------------------------------------

(define-map transactions
  ;; Key: (user principal, tx-id uint)
  ;; Value: transaction details
  {user: principal, tx-id: uint}
  {
    type: (string-ascii 10),    ;; "buy", "sell" "transfer"
    amount: uint,               ;; amount of tokens
    price: uint,                ;; price per token in microSTX (or smallest unit)
    timestamp: uint             ;; block height as timestamp proxy
  }
)

(define-map user-last-tx-id
  ;; Tracks last transaction id per user for incremental tx-ids
  {user: principal}
  {
    last-tx-id: uint
  }
)

;; --------------------------------------------
;; Constants & Vars
;; --------------------------------------------

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_TX_TYPE (err u101))
(define-constant ERR_INSUFFICIENT_TOKENS (err u102))

;; Owner controls tax rate
(define-constant CONTRACT_OWNER tx-sender)

(define-data-var tax-rate uint u15) ;; Tax rate percent (15%)

;; --------------------------------------------
;; Helper Functions
;; --------------------------------------------

(define-private (get-next-tx-id (user principal))
  (match (map-get? user-last-tx-id {user: user})
    entry
      (let (
        (next-id (+ (get last-tx-id entry) u1))
      )
        (map-set user-last-tx-id {user: user} {last-tx-id: next-id})
        next-id
      )
    ;; If no tx-id found, start with 1
    (begin
      (map-set user-last-tx-id {user: user} {last-tx-id: u1})
      u1
    )
  )
)

;; Process sell transaction using FIFO method
;; (Functionality not implemented yet. Add FIFO calculation logic here if needed.)

;; Simplified calculation to avoid complex fold operations
(define-read-only (calculate-gains-simple (user principal))
  (let (
    (last-id (default-to u0 (get last-tx-id (map-get? user-last-tx-id {user: user}))))
  )
    (if (is-eq last-id u0)
      {buys: (list), gains: u0}
      ;; For now, return a simple structure - can be enhanced later
      {buys: (list), gains: u0}
    )
  )
)

;; Core calculation function - simplified version
(define-read-only (calculate-gains-internal (user principal))
  (calculate-gains-simple user)
)

;; --------------------------------------------
;; Public Functions
;; --------------------------------------------

(define-public (set-tax-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set tax-rate new-rate)
    (ok new-rate)
  )
)

(define-public (record-transaction (tx-type (string-ascii 8)) (amount uint) (price uint))
  (let (
    (valid-types (list "buy" "sell" "transfer"))
    (tx-id (get-next-tx-id tx-sender))
    (now stacks-block-height)
  )
    (asserts! (is-some (index-of? valid-types tx-type)) ERR_INVALID_TX_TYPE)
    (map-set transactions
      {user: tx-sender, tx-id: tx-id}
      {type: tx-type, amount: amount, price: price, timestamp: now}
    )
    (ok tx-id)
  )
)

(define-read-only (get-transaction (user principal) (tx-id uint))
  (match (map-get? transactions {user: user, tx-id: tx-id})
    tx-data (ok tx-data)
    (err u404)
  )
)

;; --------------------------------------------
;; FIFO Capital Gains
;; --------------------------------------------

(define-read-only (calculate-capital-gains (user principal))
  (calculate-gains-internal user)
)

;; --------------------------------------------
;; Tax Report
;; --------------------------------------------

(define-read-only (get-tax-owed (user principal))
  (let (
    (result (calculate-gains-internal user))
    (gains (get gains result))
  )
    (/ (* gains (var-get tax-rate)) u100)
  )
)

(define-read-only (generate-report (user principal))
  (let (
    (last-id (default-to u0 (get last-tx-id (map-get? user-last-tx-id {user: user}))))
    (result (calculate-gains-internal user))
    (current-tax-rate (var-get tax-rate))
    (gains (get gains result))
    (tax-owed (/ (* gains current-tax-rate) u100))
  )
    (ok {
      user: user,
      transactions_count: last-id,
      tax_rate_percent: current-tax-rate,
      estimated_tax_owed: tax-owed
    })
  )
)