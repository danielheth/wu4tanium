using System;
using System.Collections.Generic;
using System.Text;
using WUApiLib;

namespace wu4tanium
{
    class Program
    {
        static void Main(string[] args)
        {

#if DEBUG
            Console.WriteLine("Commands Available:");
            Console.WriteLine("status");
            Console.WriteLine("available");
            Console.WriteLine("setnotificationlevel [disabled|notconfigured|notifybeforedownload|notifybeforeinstall|scheduledinstall]");
            Console.WriteLine("setschedule [mon|tue|wed|thu|fri|sat|sun] [0-23]");
            Console.Write(Environment.NewLine + "What is your selection? ");
            string input = Console.ReadLine();
            if (input.Contains(" "))
            {
                args = input.Split(' ');
            }
            else
            {
                args = new string[1];
                args[0] = input;
            }
            Console.WriteLine("");
#else
            if (args.Length <= 0)
            {
                Console.WriteLine("ERROR: Invalid parameters.");
                return;
            }
#endif

            if (args[0].Trim() == "")
            {
                Console.WriteLine("ERROR: Invalid parameters.");
#if DEBUG
                Console.WriteLine(Environment.NewLine + "Push any key to exit...");
                Console.ReadLine();
#endif
                return;
            }


            switch (args[0].ToLower())
            {
                case "status":
                    WUStatus();
                    break;
                case "setschedule":
                    string day = args[1];
                    int hour = Convert.ToInt32(args[2]);
                    SetScheduleWU(day, hour);
                    break;
                case "setnotificationlevel":
                    string newval = args[1];
                    SetNotificationLevel(newval);
                    break;
                case "available":
                    ListAvailableUpdates();
                    break;
            }

#if DEBUG
            Console.WriteLine(Environment.NewLine + "Push any key to exit...");
            Console.ReadLine();
#endif
        }

        static void WUStatus()
        {
            WindowsUpdateAgentInfo wuai = new WindowsUpdateAgentInfo();
            Console.Write((string)wuai.GetInfo("ProductVersionString"));

            AutomaticUpdatesClass auc = new WUApiLib.AutomaticUpdatesClass();
            Console.Write("|");
            Console.Write(auc.Settings.NotificationLevel.ToString().Replace("aunl", "").Replace("Installation","Install"));

            if (auc.Settings.NotificationLevel == AutomaticUpdatesNotificationLevel.aunlScheduledInstallation)
            {
                AutomaticUpdates au = new AutomaticUpdates();
                Console.Write("|");
                Console.Write(au.ServiceEnabled.ToString());

                Console.Write("|");
                Console.Write(au.Settings.ScheduledInstallationDay.ToString().Replace("ausid", "").Replace("Every", "Every ") + "|" + FixHour(au.Settings.ScheduledInstallationTime.ToString()) + ":00");
            }
            else
            {
                Console.Write("||");  //no schedule if endpoint is set to anything other than scheduled installation
            }


            Console.WriteLine("");
        }
        static string FixHour(string hour)
        {
            if (hour.Length < 2)
            {
                return "0" + hour;
            }
            else
            {
                return hour;
            }
        }

        static void SetNotificationLevel(string newval)
        {
            AutomaticUpdatesClass au = new AutomaticUpdatesClass();

            if (au.Settings.ReadOnly)
            {
                Console.WriteLine("ERROR: Settings currently read only, please run this utility as an administrator.");
                return;
            }

            switch (newval.ToLower())
            {
                case "disabled":
                    au.Settings.NotificationLevel = AutomaticUpdatesNotificationLevel.aunlDisabled;
                    break;
                case "notconfigured":
                    au.Settings.NotificationLevel = AutomaticUpdatesNotificationLevel.aunlNotConfigured;
                    break;
                case "notifybeforedownload":
                    au.Settings.NotificationLevel = AutomaticUpdatesNotificationLevel.aunlNotifyBeforeDownload;
                    break;
                case "notifybeforeinstall":
                    au.Settings.NotificationLevel = AutomaticUpdatesNotificationLevel.aunlNotifyBeforeInstallation;
                    break;
                case "scheduledinstall":
                    au.Settings.NotificationLevel = AutomaticUpdatesNotificationLevel.aunlScheduledInstallation;
                    break;
                default:
                    Console.WriteLine("ERROR: Invalid Notification Level Specified (Options: Disabled, NotConfigured, NotifyBeforeDownload, NotifyBeforeInstall, ScheduledInstall)");
                    break;
            }

            try
            {
                au.Settings.Save();
                Console.WriteLine("Windows Update Notification Level: " + newval);
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: " + ex.Message);
            }
        }

        static void SetScheduleWU(string day, int hour)
        {
            //AutomaticUpdates au = new AutomaticUpdates();

            AutomaticUpdatesClass au = new AutomaticUpdatesClass();

            if (au.Settings.ReadOnly)
            {
                Console.WriteLine("ERROR: Settings currently read only, please run this utility as an administrator.");
                return;
            }

            switch (day.ToLower())
            {
                case "all":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEveryDay;
                    break;
                case "mon":
                    
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEveryMonday;
                    break;
                case "tue":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEveryTuesday;
                    break;
                case "wed":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEveryWednesday;
                    break;
                case "thu":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEveryThursday;
                    break;
                case "fri":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEveryFriday;
                    break;
                case "sat":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEverySaturday;
                    break;
                case "sun":
                    au.Settings.ScheduledInstallationDay = AutomaticUpdatesScheduledInstallationDay.ausidEverySunday;
                    break;
                default:
                    Console.WriteLine("ERROR: Invalid Day Specified (Options: Mon, Tue, Wed, Thu, Fri, Sat, Sun)");
                    return;
            }

            if (hour >= 0 && hour <=23) {
                au.Settings.ScheduledInstallationTime = hour;
            } else {
                Console.WriteLine("ERROR: Invalid Hour Specified (Options: 0-23)");
                return;
            }

            try
            {
                au.Settings.Save();
                Console.WriteLine("Windows Update Schedule: " + day + " @ " + hour.ToString());
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: " + ex.Message);
            }
        }



        static void ListAvailableUpdates()
        {
            UpdateSession uSession = new UpdateSession();
            IUpdateSearcher uSearcher = uSession.CreateUpdateSearcher();
            uSearcher.Online = false;
            try
            {
                ISearchResult sResult = uSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0");
                //Console.WriteLine("Found " + sResult.Updates.Count + " updates");
                foreach (IUpdate update in sResult.Updates)
                {
                    Console.WriteLine(update.Title);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: " + ex.Message);
            }
        }
    
    
    
    }
}
