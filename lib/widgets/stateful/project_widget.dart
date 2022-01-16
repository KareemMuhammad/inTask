import 'package:flutter/material.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/ui/project/projectPage.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';

class ProjectWidget extends StatelessWidget {
  final ProjectModel model;

  const ProjectWidget({Key key, this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth  - 150,
      margin: const EdgeInsets.all(13.0),
      padding: const EdgeInsets.all(13.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: lightNavy,
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectPage(projectModel: model,)));
        },
        child: Column(
          children: [
            Directionality(
              textDirection: RegExp(Utils.REGEX_PATTERN).hasMatch(model.name)? TextDirection.rtl : TextDirection.ltr,
              child: Row(mainAxisAlignment: RegExp(Utils.REGEX_PATTERN).hasMatch(model.name)?
                  MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  const Icon(Icons.widgets,color: white,size: 22,),
                  const SizedBox(width: 10,),
                  Expanded(child: Text(model.name,style: TextStyle(color: white,fontSize: 19),
                    maxLines: 1,overflow: TextOverflow.ellipsis,)),
                ],
              ),
            ),
            Expanded(
              child: Align(
                  alignment: RegExp(Utils.REGEX_PATTERN).hasMatch(model.name)? Alignment.bottomLeft : Alignment.bottomRight,
                  child: Text(Utils.getProjectTimeAgo(model.date),style: TextStyle(color: white,fontSize: 17),)),
            ),
          ],
        ),
      ),
    );
  }
}
