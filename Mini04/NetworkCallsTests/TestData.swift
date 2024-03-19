//
//  TestData.swift
//  NetworkCallsTests
//
//  Created by Victor Dantas on 19/03/24.
//

import Foundation

let testFeature_nc73649170: Data = """
    {
        "id": "chatcmpl-94UZ2wPxbySJq6EnoRu2dssOq6HJg",
        "object": "chat.completion",
        "created": 1710857828,
        "model": "gpt-3.5-turbo-0125",
        "choices": [
            {
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": "Olá! Como posso ajudar você hoje?"
                },
                "logprobs": null,
                "finish_reason": "stop"
            }
        ],
        "usage": {
            "prompt_tokens": 9,
            "completion_tokens": 11,
            "total_tokens": 20
        },
        "system_fingerprint": "fp_4f2ebda25a"
    }
""".data(using: .utf8)!
