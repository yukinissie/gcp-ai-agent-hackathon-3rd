type FetchPingResult =
  {
    data: {
      id: number;
      message: string;
    } | null;
    error:
      | string
      | null;
  };

export async function fetchPing(): Promise<FetchPingResult> {
  try {
    const res =
      await fetch(
        `${process.env.RAILS_API_HOST}/api/v1/ping`,
        {
          cache:
            "no-store",
        },
      );
    if (
      !res.ok
    ) {
      if (
        res.status ===
        404
      ) {
        return {
          data: null,
          error:
            "No data found",
        };
      }
      return {
        data: null,
        error:
          "Failed to fetch data",
      };
    }
    const data =
      await res.json();
    return {
      data: data.data,
      error:
        null,
    };
  } catch (error) {
    return {
      data: null,
      error: `Failed to fetch data: ${error}`,
    };
  }
}
