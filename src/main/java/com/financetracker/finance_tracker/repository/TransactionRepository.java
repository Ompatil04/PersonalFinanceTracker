package com.financetracker.finance_tracker.repository;

import com.financetracker.finance_tracker.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByAccountId(Long accountId);
    List<Transaction> findByAccountIdAndCategory(Long accountId, String category);
    List<Transaction> findByAccountIdAndDateBetween(Long accountId, LocalDate from, LocalDate to);
}