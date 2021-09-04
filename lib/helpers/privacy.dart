import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(
              builder: (context) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil(ModalRoute.withName("/"));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          //  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 0),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black45, width: 1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.chevron_left,
                              color: Colors.black54, size: 36),
                        )
                      ],
                    ),
                  )),
        ],
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
        backwardsCompatibility:
            Theme.of(context).appBarTheme.backwardsCompatibility!,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SIMPLIFY.',
              style: Theme.of(context).textTheme.headline3,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Boxing(
                heading: "Privacy Policy",
                text:
                    "Akhil built the Simplify app as a Free app. This SERVICE is provided by Akhil at no cost and is intended for use as is. This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Simplify unless otherwise defined in this Privacy Policy.",
              ),
              Boxing(
                  heading: "Information Collection and Use",
                  text:
                      "For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to name, email/phone no. The information that I request will be retained on your device and is not collected by me in any way.The app does use third party services that may collect information used to identify you.Link to privacy policy of third party service providers used by the app\nGoogle Play Services\nGoogle Analytics for Firebase\nFirebase Crashlytics"),
              Boxing(
                heading: "Log Data",
                text:
                    "I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.",
              ),
              Boxing(
                heading: "Cookies",
                text:
                    "I may employ third-party companies and individuals due to the following reasons:\nTo facilitate our Service;\nTo provide the Service on our behalf;\nTo perform Service-related services; or\nTo assist us in analyzing how our Service is used.\nI want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
              ),
              Boxing(
                  heading: "Security",
                  text:
                      "I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security."),
              Boxing(
                  heading: "Links to Other Sites",
                  text:
                      "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services."),
              Boxing(
                  heading: "Children’s Privacy",
                  text:
                      "These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13 years of age. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions."),
              Boxing(
                  heading: "Changes to This Privacy Policy",
                  text:
                      "I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page.\nThis policy is effective as of 2021-05-07"),
              Boxing(
                  heading: "Contact Us",
                  text:
                      "If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at akhil82395@gmail.com."),
            ],
          ),
        ),
      ),
    );
  }
}

class Boxing extends StatelessWidget {
  Boxing({required this.heading, required this.text});

  final String heading;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
