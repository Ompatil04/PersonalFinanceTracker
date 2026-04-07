package com.financetracker.finance_tracker.model;

public class SpendingSummary {

    private String category;
    private Double total;
    private Integer count;

    public SpendingSummary(String category, Double total, Integer count) {
        this.category = category;
        this.total = total;
        this.count = count;
    }

    public String getCategory() { return category; }
    public Double getTotal() { return total; }
    public Integer getCount() { return count; }

    public void setCategory(String category) { this.category = category; }
    public void setTotal(Double total) { this.total = total; }
    public void setCount(Integer count) { this.count = count; }
}