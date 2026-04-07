package com.financetracker.finance_tracker.repository;

import com.financetracker.finance_tracker.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {}