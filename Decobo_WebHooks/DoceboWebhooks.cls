{\rtf1\ansi\ansicpg1252\cocoartf2639
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 @RestResource(urlMapping='/DoceboWebhooks/*')\
global class DoceboWebhooks \{\
    \
    \
    @HttpPost\
    global static string getNewUser()\{\
       \
        RestRequest req = RestContext.request;\
        RestResponse res = RestContext.response;\
        string requestedBody = req.requestBody.toString();\
        Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(requestedBody);\
       \
        String eventType = (String)body.get('event');\
        if(eventType == 'user.created')\{\
            UserResponseWrapper responseJSON=new UserResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            Integer userId =(Integer)Payload.get('user_id');\
            String userName =(string)Payload.get('username');\
            String email =(string)Payload.get('email');\
            String createdDate = (string)Payload.get('creation_date');\
            String expiration_date =(string)Payload.get('expiration_date');\
            String level = (string)Payload.get('level');\
            String firstname = (string)Payload.get('firstname');\
            String lastname = (string)Payload.get('lastname');\
            System.debug('email '+email);\
            try\{\
                if(!String.isBlank(email))\{\
                    Account myAcc = [SELECT Id, PersonEmail, Docebo_User_ID__c, Docebo_Username__c FROM Account Where PersonEmail=:email LIMIT 1];\
                    if(myAcc!=null)\{\
                        myAcc.Docebo_User_ID__c = Decimal.valueof(userId);\
                        myAcc.Docebo_Username__c = userName;\
                        DataBase.SaveResult updateAccount = Database.update(myAcc);\
                    \}\
                \}\
                \
            \}catch(Exception e)\{\
                System.debug('error '+ e.getMessage());\
            \}\
        \}\
        if(eventType=='course.created')\{\
            courseResponseWrapper courseResponseJSON=new courseResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            Integer courseId = (Integer)Payload.get('course_id');\
            String courseName = (string)Payload.get('name');\
            String courseType = (string)Payload.get('type');\
            String courseCode = (string)Payload.get('code');\
            String courseStartDate = (string)Payload.get('start_date');\
            String courseEndDate = (string)Payload.get('end_date');\
            String courselanguage =(string)Payload.get('language');\
            Integer courseDuration = (Integer)Payload.get('duration');\
            \
            try\{\
                CPD_Activity__c newCpdActivity = new CPD_Activity__c();\
                newCpdActivity.CPD_Activity_Name__c = courseName;\
                //newCpdActivity.CPD_Activity_Type__c = courseType;\
                newCpdActivity.Docebo_Course_ID__c = Decimal.valueOf(courseId);\
                newCpdActivity.Hours_Education__c = Decimal.valueOf(courseDuration);\
                DataBase.SaveResult updateCpd_Activity = Database.insert(newCpdActivity);\
                \
            \}catch(Exception e)\{\
                System.debug('error '+ e.getMessage());\
            \}            \
        \}\
        if(eventType=='course.updated')\{\
            String courseEducation='';\
            String coursePerformance='';\
            String  courseOutcomes='';\
            String courseSubscription='';\
            courseResponseWrapper courseResponseJSON=new courseResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            Integer courseId = (Integer)Payload.get('course_id');\
            String courseUpdateResponse = DoceboWebhooks.getCourseDetail(courseId);\
            Map<String,object> courseData=(Map<String,object>)JSON.deserializeUntyped(courseUpdateResponse);\
            Map<String,Object> data = (Map<String,object>)(courseData.get('data'));\
            System.debug('data. line 79' +data);\
            List<Object> additionalField = (List<Object>)(data.get('additional_fields'));\
            Map<String,Object>  CoursebackgroundImage = (Map<String,Object>)(data.get('background_image'));\
            String CoursebackgroundImageUrl = (String)CoursebackgroundImage.get('url');\
            for(Object obj:additionalField)\{\
                Map<String,Object> tempMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));\
                if(tempMap.get('title') =='Education' && String.isNotEmpty((String)tempMap.get('value')) )\{\
                    courseEducation = (String)tempMap.get('value');\
                \}else if(tempMap.get('title') =='Performance' && String.isNotEmpty((String)tempMap.get('value')))\{\
                    coursePerformance = (String)tempMap.get('value');\
                \}else if(tempMap.get('title') =='Outcomes' && String.isNotEmpty((String)tempMap.get('value')))\{\
                    courseOutcomes = (String)tempMap.get('value');\
                \}else\
                    courseSubscription = String.isNotEmpty((String)tempMap.get('value'))?(String)tempMap.get('value'):'';\
            \}\
            String courseName = (string)Payload.get('name');\
            String courseType = (string)Payload.get('type');\
            String courseCode = (string)Payload.get('code');\
            String courseStartDate = (string)Payload.get('start_date');\
            String courseEndDate = (string)Payload.get('end_date');\
            String courselanguage =(string)Payload.get('language');\
            Integer courseDuration = (Integer)Payload.get('duration');\
            Map<String,object> extraData=(Map<String,object>)body.get('extra_data');\
            System.debug('extraData '+extraData);\
            \
            try\{\
                List<CPD_Activity__c> cpdActi=new List<CPD_Activity__c>([SELECT Id, CPD_Activity_Name__c,Docebo_Course_Status__c, Hours_Education__c, Hours_Performance__c, Hours_Outcome__c, CPD_Activity_Type__c, Docebo_Course_ID__c, Name FROM CPD_Activity__c Where Docebo_Course_ID__c=:courseId]);\
                if(!cpdActi.isEmpty())\{\
                    // means Course Does not Exist in salesforce so We have call view course using corseId and then Create the cpdActsvity.\
                    System.debug('Course_update');\
                    for(CPD_Activity__c cpdActivityObj : cpdActi)\{\
                        if(!String.isBlank(courseEducation))\
                            cpdActivityObj.Hours_Education__c=Decimal.valueOf(courseEducation);\
                        if(!String.isBlank(coursePerformance))\
                            cpdActivityObj.Hours_Outcome__c=Decimal.valueOf(coursePerformance);\
                        if(!String.isBlank(courseOutcomes))\
                            cpdActivityObj.Hours_Performance__c=Decimal.valueOf(courseOutcomes);\
                        cpdActivityObj.CPD_Activity_Name__c=courseName;\
                        cpdActivityObj.Docebo_Course_ID__c=Decimal.valueOf(courseId);\
                        cpdActivityObj.Docebo_Course_Thumbnail_Image_URL__c=CoursebackgroundImageUrl;\
                        // cpdActivityObj.CPD_Activity_Type__c = courseType;\
                        \
                    \}\
                    update cpdActi;\
              \
                \}else\{\
                    CPD_Activity__c newCpdActivity = new CPD_Activity__c();\
                    newCpdActivity.CPD_Activity_Name__c = courseName;\
                    // newCpdActivity.CPD_Activity_Type__c = courseType;\
                    newCpdActivity.Docebo_Course_ID__c = Decimal.valueOf(courseId);\
                    if(!String.isBlank(courseEducation))\
                        newCpdActivity.Hours_Education__c=Decimal.valueOf(courseEducation);\
                    if(!String.isBlank(coursePerformance))\
                        newCpdActivity.Hours_Outcome__c=Decimal.valueOf(coursePerformance);\
                    if(!String.isBlank(courseOutcomes))\
                        newCpdActivity.Hours_Performance__c=Decimal.valueOf(courseOutcomes);\
                    newCpdActivity.Docebo_Course_Thumbnail_Image_URL__c=CoursebackgroundImageUrl;\
                    DataBase.SaveResult createCpd_Activity = Database.insert(newCpdActivity);\
                \}\
       \
            \}catch(Exception e)\{\
                System.debug('error '+ e.getMessage());\
            \}\
        \}\
        if(eventType=='course.deleted')\{\
            courseResponseWrapper courseResponseJSON=new courseResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            Integer courseId = (Integer)Payload.get('course_id');\
            String courseDeletionDate = (string)Payload.get('completion_date');\
            try\{\
                \
                for(CPD_Activity__c cpdActi : [SELECT Id,Docebo_Course_Status__c, Docebo_Course_ID__c FROM CPD_Activity__c Where Docebo_Course_ID__c=:courseId] )\{\
                    cpdActi.Docebo_Course_Status__c='Deleted from Docebo';\
                    DataBase.SaveResult updateCpd_Activity = Database.Update(cpdActi);\
                \}\
                \
            \}catch(Exception e)\{\
                System.debug('error '+ e.getMessage());\
            \}\
        \}\
        if(eventType=='course.enrollment.created')\{\
            System.debug('course.enrollment.created');\
            courseResponseWrapper courseResponseJSON=new courseResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            \
            Integer userId = (Integer)Payload.get('user_id');\
            String userName = (string)Payload.get('username');\
            Integer courseid = (Integer)Payload.get('course_id');\
            String courseName = (string)Payload.get('course_name');\
            String level = (string)Payload.get('level');\
            String expiration_date = (string)Payload.get('expiration_date');\
            String enrollment_date_begin_validity = (string)Payload.get('enrollment_date_begin_validity');\
            string enrollment_date_end_validity = (string)Payload.get('enrollment_date_end_validity');\
            String status = (string)Payload.get('status');\
            Map<String,object> extraData=(Map<String,object>)body.get('extra_data');\
            System.debug('extraData line 119 '+extraData);\
       \
            try\{\
                List<Account> existingUser = new List<Account>([SELECT Name, Id, PersonEmail, Docebo_User_ID__c, Docebo_Username__c FROM Account Where Docebo_User_ID__c=:userId]);\
                List<CPD_Activity__c> existingCpdActivity = new List<CPD_Activity__c>([Select Id,Docebo_Course_ID__c From CPD_Activity__c Where Docebo_Course_ID__c=: courseid]);\
                if(!existingUser.isEmpty())\{\
                    CPD_Detail__c cpdDetail = new CPD_Detail__c();\
                    cpdDetail.Account__c = existingUser[0].Id; \
                    cpdDetail.CPD_Activity__c = existingCpdActivity[0].Id;\
                    if(!String.isEmpty(enrollment_date_begin_validity))\
                        cpdDetail.Start_Date__c = date.valueOf(enrollment_date_begin_validity);\
                    if(!String.isEmpty(enrollment_date_end_validity))\
                        cpdDetail.Completion_Date__c = date.valueOf(enrollment_date_end_validity);\
                    //cpdDetail.Docebo_ID__c = ;\
                    insert cpdDetail;\
                \}\
            \}catch(Exception e)\{\
                System.debug('error '+ e.getMessage());\
            \}\
        \}\
        if(eventType=='course.enrollment.completed')\{\
            System.debug('course.enrollment.completed');\
            courseResponseWrapper courseResponseJSON=new courseResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            \
            Integer userId = (Integer)Payload.get('user_id');\
            Integer courseid = (Integer)Payload.get('course_id');\
            \
            Account acc = [SELECT  Id, PersonEmail, Docebo_User_ID__c, Docebo_Username__c FROM Account Where Docebo_User_ID__c=:userId LIMIT 1];\
            CPD_Activity__c cpdActivity = [Select Id,Docebo_Course_ID__c From CPD_Activity__c Where Docebo_Course_ID__c=: courseid LIMIT 1];\
            CPD_Detail__c cpdDetail = [SELECT Docebo_ID__c, Account__c,Activity_Status__c, CPD_Activity__c, Id FROM CPD_Detail__c Where CPD_Activity__c=:cpdActivity.Id AND Account__c=:acc.Id LIMIT 1];\
            if(cpdDetail!=null)\{\
                cpdDetail.Activity_Status__c='Completed';\
                DataBase.SaveResult updateCpdDetail = Database.Update(cpdDetail);\
            \}\
        \}\
        if(eventType=='course.enrollment.deleted')\{\
            System.debug('course.enrollment.deleted');\
            courseResponseWrapper courseResponseJSON=new courseResponseWrapper();\
            Map<String,object> Payload = (Map<String,object>)body.get('payload');\
            System.debug('Payload '+Payload);\
            \
            Integer userId = (Integer)Payload.get('user_id');\
            Integer courseid = (Integer)Payload.get('course_id');\
            Account acc = [SELECT  Id, PersonEmail, Docebo_User_ID__c, Docebo_Username__c FROM Account Where Docebo_User_ID__c=:userId LIMIT 1];\
            CPD_Activity__c cpdActivity = [Select Id,Docebo_Course_ID__c From CPD_Activity__c Where Docebo_Course_ID__c=: courseid LIMIT 1];\
            CPD_Detail__c cpdDetail = [SELECT Docebo_ID__c, Account__c,Activity_Status__c, CPD_Activity__c, Id FROM CPD_Detail__c Where CPD_Activity__c=:cpdActivity.Id AND Account__c=:acc.Id LIMIT 1];\
            if(cpdDetail!=null)\{\
                cpdDetail.Activity_Status__c='Unenrolled';\
                DataBase.SaveResult updateCpdDetail = Database.Update(cpdDetail);\
            \}   \
        \}\
        \
        \
        return 'SUCCESS';\
    \}\
    \
    public static String getAccessToken()\{\
        String client_id = 'myCpdApp';\
        String client_Secret = '27e09d50becdcdc9b7d5d54502322e74a69d3d5f';\
        String username ='prateek@cloudprism.in';\
        String password ='Winter@21';\
        Blob headerValue = Blob.valueOf(client_id + ':' + client_Secret);\
        Http http = new Http();\
        HttpRequest req = new HttpRequest();\
        req.setEndpoint('https://learn.healthcert.com/oauth2/token');\
        req.setMethod('POST');\
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);\
        req.setHeader('Authorization',authorizationHeader);\
        req.setBody('grant_type=password' +'&client_id='+client_id + '&client_secret='+client_Secret + '&username='+username + '&password='+password);\
        HTTPResponse res = http.send(req);\
        System.debug(res.getBody());\
        Map<String,object> body = (Map<String,object>)JSON.deserializeUntyped(res.getBody());\
        String acessToken =(String)body.get('access_token');\
        System.debug('acessToken'+acessToken);\
        return acessToken;\
    \}\
    \
    public static String getCourseDetail(Decimal courseId)\{\
        HttpRequest req = new HttpRequest();\
        String accessToken = DoceboWebhooks.getAccessToken();\
        System.debug('accessToken '+accessToken);\
        req.setEndpoint('https://learn.healthcert.com/learn/v1/courses/'+String.valueOf(courseId));\
        req.setMethod('GET');\
        req.setHeader('Authorization', 'Bearer ' + accessToken);\
        Http http = new Http();\
        HTTPResponse res = http.send(req);\
        Map<String,object> body = (Map<String,object>)JSON.deserializeUntyped(res.getBody());\
        Map<String,Object> data = (Map<String,object>)(body.get('data'));\
        System.debug('data '+data);\
        System.debug('additional_fields. '+data.get('additional_fields'));\
        System.debug('additional_fields. '+JSON.serializePretty(data.get('additional_fields')));\
        \
        System.debug(res.getBody());\
        return res.getBody();\
    \}\
    \
    global class UserResponseWrapper \{\
        \
        global Integer  userId \{get;set;\}\
        global String  userName \{get;set;\}\
        global String  email \{get;set;\}\
        global String  createdDate \{get;set;\}\
        global String  expiration_date \{get;set;\}\
        global String  level \{get;set;\}\
        global String  firstname  \{get;set;\}\
        global String  lastname  \{get;set;\}\
        global String  fired_at  \{get;set;\}\
        global String  provisioned  \{get;set;\}\
        global UserResponseWrapper()\{\
            \
        \}\
    \}\
    \
    global class courseResponseWrapper\{\
        global Integer  courseId \{get;set;\}\
        global String  courseName \{get;set;\}\
        global String  courseType \{get;set;\}\
        global String  courseCode \{get;set;\}\
        global String  courseStartDate \{get;set;\}\
        global String  courseEndDate \{get;set;\}\
        global String  courselanguage  \{get;set;\}\
        global Integer  courseDuration  \{get;set;\}\
        global Integer  courseDeletionDate  \{get;set;\}\
        global String  courseEducation  \{get;set;\}\
        global String  coursePerformance  \{get;set;\}\
        global String  courseOutcomes   \{get;set;\}\
        global String  courseSubscription   \{get;set;\}\
        global String  CoursebackgroundImageUrl   \{get;set;\}\
       \
        global courseResponseWrapper()\{\
            \
        \}\
        \
    \}\
    \
    global class enrollmentResponseWrapper\{\
        global Integer  userid  \{get;set;\}\
        global String  userName  \{get;set;\}\
        global Integer  courseid  \{get;set;\}\
        global String  courseName  \{get;set;\}\
        global String  level  \{get;set;\}\
        global String  enrollment_date  \{get;set;\}\
        global String  enrollment_date_begin_validity   \{get;set;\}\
        global String  enrollment_date_end_validity \{get;set;\}\
        global String  status    \{get;set;\}\
        global String  completion_date     \{get;set;\}\
       \
        global enrollmentResponseWrapper()\{\
            \
        \}\
        \
    \}\
    \
\}}