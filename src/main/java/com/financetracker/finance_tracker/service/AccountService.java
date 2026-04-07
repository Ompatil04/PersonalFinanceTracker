package com.financetracker.finance_tracker.service;

import com.financetracker.finance_tracker.model.Account;
import com.financetracker.finance_tracker.model.User;
import com.financetracker.finance_tracker.repository.AccountRepository;
import com.financetracker.finance_tracker.repository.UserRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class AccountService {

    private final AccountRepository accountRepo;
    private final UserRepository userRepo;

    public AccountService(AccountRepository accountRepo, UserRepository userRepo) {
        this.accountRepo = accountRepo;
        this.userRepo = userRepo;
    }

    public Account create(Long userId, String name, Account.AccountType type) {
        User user = userRepo.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found: " + userId));
        Account a = new Account();
        a.setUser(user);
        a.setName(name);
        a.setType(type);
        a.setBalance(0.0);
        return accountRepo.save(a);
    }

    public List<Account> findByUser(Long userId) {
        return accountRepo.findByUserId(userId);
    }

    public Account findById(Long id) {
        return accountRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found: " + id));
    }
}
