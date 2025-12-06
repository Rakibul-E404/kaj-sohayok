import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/service/get_storage.dart';
import 'package:kaz_bd/utilities/app_constants.dart';

import '../features/normal_user/chat_inbox/model/chat_individual_message_model.dart';
import '../features/normal_user/chat_inbox/presentation/chat_inbox_screen.dart';
import '../features/normal_user/chat_list/model/chat_list_response_model.dart';
import '../service/network_caller.dart';
import '../service/network_response.dart';
import '../service/socket_service.dart';
import '../utilities/app_url.dart';
import '../utilities/logger_util.dart';

class MessageScreenController extends GetxController {
  TextEditingController messageScreenSearchController = TextEditingController();
  var searchText = ''.obs;
  final RxBool loader = false.obs;
  final RxList<ChatListResponseModel> chatLists = <ChatListResponseModel>[].obs;

  createMessage() async {
    loader.value = true;

    final Map<String, dynamic> loginForm = <String, dynamic>{
      "participants": ["69313d9f5e9dc3dec1639dc1"],
      "message": "as p1 -> us1 ... init" //
    };

    final NetworkResponse postResponse = await NetworkCaller().postRequest(
      AppUrl.createConversation,
      body: loginForm,
    );
    if (postResponse.isSuccess) {
      LoggerUtils.debug(postResponse.jsonResponse);
    }
  }

  @override
  Future<void> onInit() async {
    final String userId = GetStorageModel().read(AppConstants.userId);
    SocketServices().listen("conversation-list-updated::$userId",
        (dynamic data) {
      LoggerUtils.warning(data);
      // debugPrint("notifications data : $data");
    });
    SocketServices().listen("related-user-online-status::$userId",
        (dynamic data) {
      LoggerUtils.warning(data);
      // debugPrint("notifications data : $data");
    });
    SocketServices().listen("notification::$userId", (dynamic data) {
      LoggerUtils.warning(data);
      // debugPrint("notifications data : $data");
    });
    SocketServices().listen("get-all-conversations-with-pagination",
        (dynamic data) {
      LoggerUtils.error(data);
      // debugPrint("notifications data : $data");
    });
    await handleFetchChatList();
    super.onInit();
  }

  // ================== Handle the Chat List Fetching ===============>
  handleFetchChatList() async {
    try {
      final chatListResponse = await SocketServices().emitAsync(
        "get-all-conversations-with-pagination",
        {"page": 1, "limit": 50000, "search": ""},
      );

      if (chatListResponse != null) {
        chatLists.clear();
        final resultList = chatListResponse['data']['results'];
        //   LoggerUtils.warning(resultList);
        //   chatLists.addAll(resultList
        //       .map((e) => ChatListResponseModel.fromJson(e as Map<String, dynamic>))
        //       .toList());
        // }
        for (final result in resultList) {
          final ChatListResponseModel model = ChatListResponseModel.fromJson(
            result as Map<String, dynamic>,
          );
          chatLists.add(model);
        }
      }
    } catch (e) {
      // ToastManager.show(
      //   message: e.toString(),
      //   backgroundColor: AppColors.red,
      //   textColor: AppColors.white,
      // );
      LoggerUtils.debug("Exception : ${e.toString()}");
    } finally {}
  }

  // ================== Handle the individual messaging ==========>
  final RxList<IndividualChatMessage> individualChatLists =
      <IndividualChatMessage>[].obs;

  handleViewSingleProfileChat({required String conversationId}) async {
    final chatListResponse = await SocketServices().emitAsync(
      "get-all-message-by-conversationId",
      {
        // for get-all-message-by-conversationId
        "conversationId": conversationId,
        "page": 1,
        "limit": 50000000
      },
    );

    if (chatListResponse != null) {
      individualChatLists.clear();
      final resultList = chatListResponse['data']['results'];
      //   LoggerUtils.warning(resultList);
      //   chatLists.addAll(resultList
      //       .map((e) => ChatListResponseModel.fromJson(e as Map<String, dynamic>))
      //       .toList());
      // }
      for (final result in resultList) {
        final IndividualChatMessage model = IndividualChatMessage.fromJson(
          result as Map<String, dynamic>,
        );
        individualChatLists.add(model);
      }
    }
  }
}
