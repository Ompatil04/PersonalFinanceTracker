package com.financetracker.finance_tracker.service;

import com.financetracker.finance_tracker.model.*;
import com.financetracker.finance_tracker.repository.*;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TransactionService {

    private final TransactionRepository txRepo;
    private final AccountRepository accountRepo;

    public TransactionService(TransactionRepository txRepo, AccountRepository accountRepo) {
        this.txRepo = txRepo;
        this.accountRepo = accountRepo;
    }

    public Transaction addTransaction(Long accountId, Double amount, String category,
                                      String description, Transaction.TransactionType type,
                                      String date) {
        Account account = accountRepo.findById(accountId)
            .orElseThrow(() -> new RuntimeException("Account not found: " + accountId));

        Transaction tx = new Transaction();
        tx.setAccount(account);
        tx.setAmount(amount);
        tx.setCategory(category);
        tx.setDescription(description);
        tx.setType(type);
        tx.setDate(LocalDate.parse(date));

        if (type == Transaction.TransactionType.INCOME) {
            account.setBalance(account.getBalance() + amount);
        } else {
            account.setBalance(account.getBalance() - amount);
        }
        accountRepo.save(account);
        return txRepo.save(tx);
    }

    public List<SpendingSummary> getSpendingSummary(Long accountId) {
        return txRepo.findByAccountId(accountId).stream()
            .filter(t -> t.getType() == Transaction.TransactionType.EXPENSE)
            .collect(Collectors.groupingBy(
                Transaction::getCategory,
                Collectors.summarizingDouble(Transaction::getAmount)
            ))
            .entrySet().stream()
            .map(e -> new SpendingSummary(
                e.getKey(),
                e.getValue().getSum(),
                (int) e.getValue().getCount()
            ))
            .toList();
    }
}