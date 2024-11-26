;; title: mullti-sig-wallet
;; Multi-Signature Wallet Smart Contract

;; Errors
(define-constant ERR-NOT-OWNER (err u1))
(define-constant ERR-INSUFFICIENT-SIGNATURES (err u2))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u3))
(define-constant ERR-ALREADY-SIGNED (err u4))
(define-constant ERR-TRANSACTION-ALREADY-EXECUTED (err u5))
(define-constant ERR-TRANSACTION-FAILED (err u6))

;; Data structures
(define-map owners principal bool)
(define-map proposals 
  uint
  {
    signatures: (list 10 principal),
    executed: bool,
    to: principal,
    amount: uint
  }
)

;; Variables
(define-data-var next-proposal-id uint u0)
(define-data-var required-signatures uint u0)

;; Initialize the multi-sig wallet
(define-public (initialize-wallet (wallet-owners (list 10 principal)) (min-signatures uint))
  (begin
    ;; Ensure at least one owner and valid signature requirement
    (asserts! (> (len wallet-owners) u0) (err u6))
    (asserts! (> min-signatures u0) (err u7))
    (asserts! (<= min-signatures (len wallet-owners)) (err u8))
    
    ;; Add owners to the map
    (map set-owner wallet-owners)
    
    ;; Set required signatures
    (var-set required-signatures min-signatures)
    
    (ok true)
  )
)

;; Helper function to add owners to the owners map
(define-private (set-owner (owner principal))
  (map-set owners owner true)
)

;; Check if sender is an owner
(define-private (is-owner (sender principal))
  (default-to false (map-get? owners sender))
)

;; Propose a transaction
(define-public (propose-transaction (to principal) (amount uint))
  (let 
    (
      (proposal-id (var-get next-proposal-id))
      (sender tx-sender)
    )
    ;; Ensure only owners can propose
    (asserts! (is-owner sender) ERR-NOT-OWNER)
    
    ;; Create proposal
    (map-set proposals 
      proposal-id
      {
        to: to, 
        amount: amount,
        signatures: (list), 
        executed: false
      }
    )
    
    ;; Increment proposal ID
    (var-set next-proposal-id (+ proposal-id u1))
    
    (ok proposal-id)
  )
)

;; Sign a proposal
(define-public (sign-proposal (proposal-id uint))
  (let 
    (
      (sender tx-sender)
      (proposal (unwrap! 
        (map-get? proposals proposal-id) 
        ERR-PROPOSAL-NOT-FOUND
      ))
      (current-signatures (get signatures proposal))
      (executed (get executed proposal))
      (recipient (get to proposal))
      (amount (get amount proposal))
    )
    ;; Checks
    (asserts! (is-owner sender) ERR-NOT-OWNER)
    (asserts! (not executed) ERR-TRANSACTION-ALREADY-EXECUTED)
    (asserts! (is-none (index-of? current-signatures sender)) ERR-ALREADY-SIGNED)
    
    ;; Add signature
    (let 
      (
        (updated-signatures (unwrap! (as-max-len? (append current-signatures sender) u10) (err u9)))
      )
      ;; Update proposal with new signatures
      (map-set proposals 
        proposal-id
        {
          to: recipient,
          amount: amount,
          signatures: updated-signatures, 
          executed: (>= (len updated-signatures) (var-get required-signatures))
        }
      )
      
      ;; If enough signatures, execute transaction
      (if (>= (len updated-signatures) (var-get required-signatures))
        (execute-transaction proposal-id)
        (ok true)
      )
    )
  )
)

;; Execute a transaction with enough signatures
(define-private (execute-transaction (proposal-id uint))
  (let 
    (
      (proposal (unwrap! 
        (map-get? proposals 
            proposal-id
        ) 
        ERR-PROPOSAL-NOT-FOUND
      ))
      (to (get to proposal))
      (amount (get amount proposal))
    )
    ;; Transfer tokens
    (unwrap! (stx-transfer? amount tx-sender to) ERR-TRANSACTION-FAILED)
    
    ;; Mark as executed
    (map-set proposals 
        proposal-id
      {
        to: to,
        amount: amount,
        signatures: (get signatures proposal), 
        executed: true
      }
    )
    
    (ok true)
  )
)

;; Getter functions
(define-read-only (get-proposal-recipient (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (some (get to proposal))
    none
  )
)

(define-read-only (get-proposal-amount (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (some (get amount proposal))
    none
  )
)

(define-read-only (get-proposal-signatures (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (some (get signatures proposal))
    none
  )
)

(define-read-only (get-proposal-executed-status (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (some (get executed proposal))
    none
  )
)

