import {
  NextRequest,
  NextResponse,
} from "next/server";
import { auth } from "@/auth";

// Mastra toolからfetchUserAttributes関数をimport
async function testFetchUserAttributes(
  userId: number,
) {
  try {
    console.log(
      "🚀 API Route: Starting fetchUserAttributes test for userId:",
      userId,
    );

    // セッション確認
    const session =
      await auth();
    console.log(
      "👤 API Route: Session:",
      session?.user
        ? "Authenticated"
        : "Not authenticated",
    );
    console.log(
      "🔑 API Route: JWT Token:",
      session
        ?.user
        ?.jwtToken
        ? "Present"
        : "Missing",
    );

    if (
      !session
        ?.user
        ?.jwtToken
    ) {
      return {
        success: false,
        error:
          "Authentication required",
      };
    }

    // Direct import to avoid module resolution issues
    const {
      apiClient,
    } =
      await import(
        "../../../lib/api-client"
      );

    console.log(
      "📡 API Route: Calling Rails API /api/v1/user_attributes...",
    );
    const data =
      await apiClient.get(
        "/api/v1/user_attributes",
      );

    console.log(
      "✅ API Route: Raw Rails API response received",
    );
    console.log(
      "📊 API Route: Response data:",
      JSON.stringify(
        data,
        null,
        2,
      ),
    );

    return {
      success: true,
      rawData:
        data,
    };
  } catch (error) {
    console.error(
      "❌ API Route: Error occurred:",
      error,
    );
    console.error(
      "❌ API Route: Error type:",
      error
        ?.constructor
        ?.name,
    );
    console.error(
      "❌ API Route: Error message:",
      error instanceof
        Error
        ? error.message
        : "Unknown error",
    );

    return {
      success: false,
      error:
        error instanceof
        Error
          ? error.message
          : "Unknown error",
      errorType:
        error
          ?.constructor
          ?.name,
    };
  }
}

export async function POST(
  request: NextRequest,
) {
  console.log(
    "🧪 API Route: Starting user attributes test...",
  );

  try {
    const result =
      await testFetchUserAttributes(
        1,
      ); // Test with user ID 1

    console.log(
      "📋 API Route: Test completed:",
      result.success
        ? "✅ SUCCESS"
        : "❌ FAILED",
    );

    return NextResponse.json(
      result,
    );
  } catch (error) {
    console.error(
      "❌ API Route: Unexpected error:",
      error,
    );

    return NextResponse.json(
      {
        success: false,
        error:
          error instanceof
          Error
            ? error.message
            : "Unexpected error",
        stack:
          error instanceof
          Error
            ? error.stack
            : undefined,
      },
      {
        status: 500,
      },
    );
  }
}
