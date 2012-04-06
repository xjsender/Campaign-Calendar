public with sharing class ExtViewCampaignByMonth {
    
    public List<Campaign> cams                                {get; set;}
    public List<String> headers                               {get; set;}
    public Date startDate                                     {get; set;}
    public String dateText                                    {get; set;}
    public List<Integer> days                                 {get; set;}
    public List<Date> fullDates                               {get; set;} 
    public List<SplitDates> splitDates                        {get; set;}
    
    private final Integer COLUMN_SIZE = 7;
    
    public ExtViewCampaignByMonth() {
        headers = UtiCampaign.getHeaders();
        populateDateAndCampaigns(System.today());
    }
    
    // Inner class for binding date with Campaigns in this Date.
    public class DateCampaigns {
        
        public Date sDate                       {get; set;}
        public Boolean isInCurrentMonth         {get; set;}
        public List<Campaign> campsInsDate      {get; set;}
        
        public DateCampaigns (Date sDate, Boolean isInCurrentMonth, List<Campaign> campsInsDate) {
            this.sDate = sDate;
            this.isInCurrentMonth = isInCurrentMonth;
            this.campsInsDate = campsInsDate;
        }
    }
    
    public class SplitDates {
        public List<DateCampaigns> dateCams      {get; set;}
        public SplitDates(List<DateCampaigns> dateCams) {
            this.dateCams = dateCams;
        }
    }
    
    public void populateDateAndCampaigns(Date paramDate) {
        // Get the First Date of current Month
        startDate = Date.newInstance(paramDate.year(), paramDate.month(), 1);
        
        // For example: March, 2012
        dateText = UtiCampaign.getOutputDate(startDate);
        
        // Get the dates of current month
        fullDates = UtiCampaign.getFullDatesOfCurrentMonth(startDate);
        Set<Date> datesInCurrentMonth = UtiCampaign.getDatesOfCurrentMonth(startDate);
        
        try {
            cams = [SELECT Id, Name, StartDate, EndDate 
                    FROM Campaign 
                    WHERE StartDate >=: startDate 
                    AND StartDate < :startDate.addMonths(1)];
        }
        catch (QueryException e) {
            cams = new List<Campaign>();
        }

        // Initial dateCams
        splitDates = new List<SplitDates>();
        Integer weeks = Math.mod(fullDates.size(), COLUMN_SIZE) == 0 ? fullDates.size() / COLUMN_SIZE : 
                                                                       fullDates.size() / COLUMN_SIZE + 1;
        for (Integer i = 0; i < weeks; i++) {
            List<DateCampaigns> dateCams = new List<DateCampaigns>();
            for (Integer j = i * 7; j < COLUMN_SIZE + i * 7; j++) {
                
                // Prevent ListOutbound
                if (j > fullDates.size() - 1) {
                    break;
                }
                
                Date sDate = fullDates.get(j);
                List<Campaign> camsInDate = new List<Campaign>();
                for (Campaign cam : cams) {
                    Set<Date> datesBetweenStartDateAndEndDate = UtiCampaign.getDateSet(cam.StartDate, cam.EndDate);
                    if (datesBetweenStartDateAndEndDate.contains(sDate)) {
                        camsInDate.add(cam);
                    }
                }
                dateCams.add(new DateCampaigns(sDate, datesInCurrentMonth.contains(sDate), camsInDate));
            }
            splitDates.add(new SplitDates(dateCams));
        }
    }
    
    public PageReference nextMonth() {
        populateDateAndCampaigns(startDate.addMonths(1));
        return null;
    }

    public PageReference previousMonth() {
        populateDateAndCampaigns(startDate.addMonths(-1));
        return null;
    }
    
    public PageReference thisMonth() {
        populateDateAndCampaigns(System.today());
        return null;
    }
    
    public PageReference save() {
        return null;
    }

}