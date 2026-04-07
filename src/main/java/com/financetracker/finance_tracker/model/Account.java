package com.financetracker.finance_tracker.model;

import jakarta.persistence.*;
import java.util.*;

@Entity
public class Account {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Enumerated(EnumType.STRING)
    private AccountType type;

    private Double balance = 0.0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "account", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Transaction> transactions = new ArrayList<>();

    public enum AccountType { CHECKING, SAVINGS, CREDIT }

    public Long getId() { return id; }
    public String getName() { return name; }
    public AccountType getType() { return type; }
    public Double getBalance() { return balance; }
    public User getUser() { return user; }
    public List<Transaction> getTransactions() { return transactions; }

    public void setId(Long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setType(AccountType type) { this.type = type; }
    public void setBalance(Double balance) { this.balance = balance; }
    public void setUser(User user) { this.user = user; }
    public void setTransactions(List<Transaction> transactions) { this.transactions = transactions; }
}