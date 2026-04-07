package com.financetracker.finance_tracker.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double amount;
    private String category;
    private String description;

    @Enumerated(EnumType.STRING)
    private TransactionType type;

    private LocalDate date;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id")
    private Account account;

    public enum TransactionType { INCOME, EXPENSE }

    public Long getId() { return id; }
    public Double getAmount() { return amount; }
    public String getCategory() { return category; }
    public String getDescription() { return description; }
    public TransactionType getType() { return type; }
    public LocalDate getDate() { return date; }
    public Account getAccount() { return account; }

    public void setId(Long id) { this.id = id; }
    public void setAmount(Double amount) { this.amount = amount; }
    public void setCategory(String category) { this.category = category; }
    public void setDescription(String description) { this.description = description; }
    public void setType(TransactionType type) { this.type = type; }
    public void setDate(LocalDate date) { this.date = date; }
    public void setAccount(Account account) { this.account = account; }
}