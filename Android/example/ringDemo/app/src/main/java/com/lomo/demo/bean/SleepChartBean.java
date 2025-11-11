package com.lomo.demo.bean;

public class SleepChartBean {
    int  sleepType;
    String  startTime;
    String  endTime;
    long startLongTime;
    long endLongTime;
    public SleepChartBean(int  sleepType, String  startTime, String  endTime) {
        this.sleepType = sleepType;
        this.startTime = startTime;
        this.endTime = endTime;
    }
    public SleepChartBean(int  sleepType, long  startTime, long  endTime) {
        this.sleepType = sleepType;
        this.startLongTime = startTime;
        this.endLongTime = endTime;
    }

    public long getStartLongTime() {
        return startLongTime;
    }

    public void setStartLongTime(long startLongTime) {
        this.startLongTime = startLongTime;
    }

    public long getEndLongTime() {
        return endLongTime;
    }

    public void setEndLongTime(long endLongTime) {
        this.endLongTime = endLongTime;
    }

    public int getSleepType() {
        return sleepType;
    }

    public void setSleepType(int sleepType) {
        this.sleepType = sleepType;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
}
